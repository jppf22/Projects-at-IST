#!/usr/bin/python3
# Copyright (c) BDist Development Team
# Distributed under the terms of the Modified BSD License.
import os
from logging.config import dictConfig

from flask import Flask, jsonify, request
from psycopg.rows import namedtuple_row
from psycopg_pool import ConnectionPool

from datetime import datetime

# Use the DATABASE_URL environment variable if it exists, otherwise use the default.
# Use the format postgres://username:password@hostname/database_name to connect to the database.
DATABASE_URL = os.environ.get("DATABASE_URL", "postgres://postgres:postgres@postgres/postgres")

pool = ConnectionPool(
    conninfo=DATABASE_URL,
    kwargs={
        "autocommit": True,  # If True don’t start transactions automatically.
        "row_factory": namedtuple_row,
    },
    min_size=4,
    max_size=10,
    open=True,
    # check=ConnectionPool.check_connection,
    name="postgres_pool",
    timeout=5,
)

dictConfig(
    {
        "version": 1,
        "formatters": {
            "default": {
                "format": "[%(asctime)s] %(levelname)s in %(module)s:%(lineno)s - %(funcName)20s(): %(message)s",
            }
        },
        "handlers": {
            "wsgi": {
                "class": "logging.StreamHandler",
                "stream": "ext://flask.logging.wsgi_errors_stream",
                "formatter": "default",
            }
        },
        "root": {"level": "INFO", "handlers": ["wsgi"]},
    }
)

app = Flask(__name__)
app.config.from_prefixed_env()
log = app.logger


def is_decimal(s):
    """Returns True if string is a parseable float number."""
    try:
        float(s)
        return True
    except ValueError:
        return False

def check_exists_clinic(cur, clinica):
    clinic_exists = cur.execute(
                """
                SELECT 1
                FROM clinica
                WHERE nome = %(clinica)s;
                """,
                {'clinica': clinica},
    ).fetchone()

    if clinic_exists is None:
        return False
    else:
        return True
    

@app.route("/", methods=("GET",))
def show_clinics():
    """Shows all clinics, name followed by adress."""
    with pool.connection() as conn:
        with conn.cursor() as cur:
            clinics = cur.execute(
                """
                SELECT nome, morada FROM clinica;
                """,
                {},
            ).fetchall()
            log.debug(f"Found {cur.rowcount} rows.")
    
    return jsonify(clinics), 200

@app.route("/c/<clinica>/", methods=("GET",))
def clinic_show_speciality(clinica):
    """Shows all medic specialities offered in a certain clinic"""

    clinica = str(clinica)

    with pool.connection() as conn:
        with conn.cursor() as cur:

            if check_exists_clinic(cur,clinica) is False:
                return jsonify({"message": "Clinic not found.", "status": "error"}), 404

            list_specialities = cur.execute(
                """
                SELECT DISTINCT especialidade
                FROM clinica c JOIN trabalha t ON c.nome = t.nome JOIN medico m ON t.nif = m.nif 
                WHERE c.nome = %(clinica)s;
                """,
                {'clinica': clinica},
            ).fetchall()
            log.debug(f"Found {cur.rowcount} rows.")

    # At the end of the `connection()` context, the transaction is committed
    # or rolled back, and the connection returned to the pool.

    if not list_specialities:
        return jsonify({"message": "No specialties found for this clinic.", "status": "success"}), 200

    return jsonify(list_specialities), 200

@app.route("/c/<clinica>/<especialidade>", methods=("GET",),)
def list_first_3_available_slots_per_medic(clinica, especialidade):
    """Shows the first three available appointments all medics that work on a clinic in a specific speciality"""

    clinica = str(clinica)
    especialidade = str(especialidade)

    with pool.connection() as conn:
        with conn.cursor() as cur:
            
            if check_exists_clinic(cur,clinica) is False:
                return jsonify({"message": "Clinic not found.", "status": "error"}), 404

            current_day = str(datetime.today().date())
            current_hour = datetime.today().strftime("%H:%M")

            list_slots = cur.execute(
                """
                SELECT 
                    m.nome,
                    ARRAY_AGG(CONCAT(h_sorted.data, ' ', h_sorted.hora)) AS horarios_disponiveis
                FROM medico m 
                JOIN (
                    SELECT h.*, 
                        ROW_NUMBER() OVER (PARTITION BY h.nif ORDER BY h.data, h.hora) AS row_num 
                    FROM horarios h 
                    WHERE h.nome = %(clinica)s AND (h.data > %(dia_atual)s OR (h.data = %(dia_atual)s AND h.hora > %(hora_atual)s))
                ) AS h_sorted 
                ON m.nif = h_sorted.nif 
                WHERE m.especialidade = %(especialidade)s  AND h_sorted.row_num <= 3
                GROUP BY m.nome
                ORDER BY m.nome;
                """,
                {'clinica': clinica, 'especialidade': especialidade, 'dia_atual': current_day, 'hora_atual': current_hour},
            ).fetchall()
            log.debug(f"Found {cur.rowcount} rows.")

    # At the end of the `connection()` context, the transaction is committed
    # or rolled back, and the connection returned to the pool.

    if list_slots is None or len(list_slots) == 0:
        return jsonify({"message": "No available slots found for this clinic and specialty", "status": "success"}), 200

    return jsonify(list_slots), 200

@app.route(
        "/a/<clinica>/registar/",
        methods = (
            "PUT",
            "POST",
        ),
)

def registra_consulta(clinica):
    """Tries to register an appointment at a certain clinic"""
    
    clinica = str(clinica)
    paciente_ssn = request.args.get("paciente_ssn")
    nome_medico = request.args.get("nome_medico")
    data = request.args.get("data")
    hora = request.args.get("hora")

    error = None

    # Check if paciente_ssn is provided and if it is a decimal
    if not paciente_ssn:
        error = "Patient SSN is required to create appointment."
    elif not is_decimal(paciente_ssn):
        error = "Patient SSN is required to be decimal."

    # Check if nome_medico is provided
    if not nome_medico:
        error = "Medic's Name is required to create appointment."

    # Check if data is provided and if it is in the format YYYY-MM-DD
    if not data:
        error = "A date is required to create appointment."
    else:
        try:
            datetime.strptime(data, "%Y-%m-%d")
        except ValueError:
            error = "Date must be in the format YYYY-MM-DD."

    # Check if hora is provided and if it is in the format HH:MM
    if not hora:
        error = "An hour is required to create appointment."
    else:
        try:
            datetime.strptime(hora, "%H:%M")
        except ValueError:
            error = "Hour must be in the format HH:MM."

    if error is not None:
        return jsonify({"message": error, "status": "error"}), 400
    else:
        with pool.connection() as conn:
            with conn.cursor() as cur:
                
                if check_exists_clinic(cur,clinica) is False:
                    return jsonify({"message": "Clinic not found.", "status": "error"}), 404

                current_day = str(datetime.today().date())
                current_hour = datetime.today().strftime("%H:%M")

                try:
                    with conn.transaction():
                        # BEGIN is executed, a transaction started

                        # Adds the consulta if possible and valid
                        cur.execute(
                            """
                            WITH last_codigo AS (
                                SELECT LPAD(CAST(COALESCE(MAX(codigo_sns::bigint) + 1, 1) AS VARCHAR), 12, '0') AS new_codigo_sns
                                FROM consulta
                            )
                            INSERT INTO consulta (ssn, nif, nome, data, hora, codigo_sns)
                            SELECT %(paciente_ssn)s, h.nif, h.nome, h.data, h.hora, lc.new_codigo_sns
                            FROM medico m
                            JOIN (
                                SELECT nif, nome, data, hora
                                FROM horarios
                                WHERE data > %(current_day)s 
                                OR (data = %(current_day)s AND hora > %(current_hour)s)
                            ) AS h ON m.nif = h.nif
                            JOIN last_codigo lc ON TRUE
                            WHERE m.nome = %(nome_medico)s
                            AND h.data = %(data)s
                            AND h.hora = %(hora)s
                            LIMIT 1;
                            """,
                            {
                                "paciente_ssn": paciente_ssn,
                                "nome_medico": nome_medico,
                                "clinica": clinica,
                                "data": data,
                                "hora": hora,
                                "current_day": current_day,
                                "current_hour": current_hour
                            }
                        )

                        # Removes the valid slot from the horarios table
                        cur.execute(
                            """
                            DELETE FROM horarios
                            WHERE nif IN (
                                SELECT nif
                                FROM medico
                                WHERE nome = %(nome_medico)s
                            )
                            AND data = %(data)s
                            AND hora = %(hora)s;
                            """,
                            {
                                "nome_medico": nome_medico,
                                "data": data,
                                "hora": hora
                            },
                        )

                        # These operation runs atomically in this transaction
                
                except Exception as e:
                    log.error(f"SQL execution error: {e}")
                    return jsonify({"message": str(e), "status": "error"}), 500
                else:
                    # COMMIT is executed at the end of the block.
                    # The connection is in idle state again.

                    rows = cur.rowcount

                    log.debug(f"Added {rows} rows to consulta.")
                    log.debug(f"Deleted {rows} rows from horarios.")

                    if rows == 0:
                        return (
                            jsonify({"message": "The specified slot is not available", "status": "error"}),
                            404,
                        )

    # The connection is returned to the pool at the end of the `connection()` context

    return "", 204      

@app.route(
    "/a/<clinica>/cancelar/",
    methods = (
        "DELETE",
        "POST",
    ), 
)
def cancelar_consulta(clinica):
    """ Tries to cancel a previously schedule appointment at a clinic """

    clinica = str(clinica)
    paciente_ssn = request.args.get("paciente_ssn")
    nome_medico = request.args.get("nome_medico")
    data = request.args.get("data")
    hora = request.args.get("hora")

    error = None

    # Check if paciente_ssn is provided and if it is a decimal
    if not paciente_ssn:
        error = "Patient SSN is required to cancel appointment."
    elif not is_decimal(paciente_ssn):
        error = "Patient SSN is required to be decimal."

    # Check if nome_medico is provided
    if not nome_medico:
        error = "Medic's Name is required to cancel appointment."

    # Check if data is provided and if it is in the format YYYY-MM-DD
    if not data:
        error = "A date is required to cancel appointment."
    else:
        try:
            datetime.strptime(data, "%Y-%m-%d")
        except ValueError:
            error = "Date must be in the format YYYY-MM-DD."

    # Check if hora is provided and if it is in the format HH:MM
    if not hora:
        error = "An hour is required to cancel appointment."
    else:
        try:
            datetime.strptime(hora, "%H:%M")
        except ValueError:
            error = "Hour must be in the format HH:MM."

    if error is not None:
        return jsonify({"message": error, "status": "error"}), 400
    else:
        with pool.connection() as conn:
            with conn.cursor() as cur:
                
                if check_exists_clinic(cur,clinica) is False:
                    return jsonify({"message": "Clinic not found.", "status": "error"}), 404

                current_day = str(datetime.today().date())
                current_hour = datetime.today().strftime("%H:%M")

                try:
                    with conn.transaction():
                        # BEGIN is executed, a transaction started

                        consulta_existe = cur.execute(
                            """
                            SELECT * FROM consulta c
                            WHERE c.ssn = %(paciente_ssn)s
                            AND c.nif IN (
                                SELECT nif
                                FROM medico m
                                WHERE m.nome = %(nome_medico)s
                            )
                            AND c.nome = %(clinica)s
                            AND c.data = %(data)s
                            AND c.hora = %(hora)s
                            AND (c.data > %(current_day)s OR (c.data = %(current_day)s AND c.hora > %(current_hour)s));
                            """,
                            {
                                "paciente_ssn": paciente_ssn,
                                "nome_medico": nome_medico,
                                "clinica": clinica,
                                "data": data,
                                "hora": hora,
                                "current_day": current_day,
                                "current_hour": current_hour
                            }
                        ).fetchall()

                        if len(consulta_existe) == 0:
                            raise Exception("The appointment doesn't exist.")
                        
                        # Removes the consulta if possible and valid
                        cur.execute(
                            """
                            DELETE FROM consulta c
                            WHERE c.ssn = %(paciente_ssn)s
                            AND c.nif IN (
                                SELECT nif
                                FROM medico m
                                WHERE m.nome = %(nome_medico)s
                            )
                            AND c.nome = %(clinica)s
                            AND c.data = %(data)s
                            AND c.hora = %(hora)s
                            AND (c.data > %(current_day)s OR (c.data = %(current_day)s AND c.hora > %(current_hour)s));
                            """,
                            {
                                "paciente_ssn": paciente_ssn,
                                "nome_medico": nome_medico,
                                "clinica": clinica,
                                "data": data,
                                "hora": hora,
                                "current_day": current_day,
                                "current_hour": current_hour
                            }
                        )

                        # Adds the valid slot to horarios table
                        cur.execute(
                            """
                            INSERT INTO horarios (nif, nome, data, hora)
                            SELECT nif, %(clinica)s, %(data)s, %(hora)s
                            FROM medico
                            WHERE nome = %(nome_medico)s;
                            """,
                            {
                                "nome_medico": nome_medico,
                                "clinica": clinica,
                                "data": data,
                                "hora": hora
                            }
                        )

                        # These operation runs atomically in this transaction
                except Exception as e:
                    log.error(f"SQL execution error: {e}")
                    return jsonify({"message": str(e), "status": "error"}), 500
                else:
                    # COMMIT is executed at the end of the block.
                    # The connection is in idle state again.
                    rows = cur.rowcount
                    log.debug(f"Deleted {rows} rows from consulta.")
                    log.debug(f"Added {rows} rows to horarios.")

    # The connection is returned to the pool at the end of the `connection()` context
    return "", 204   

@app.route("/ping", methods=("GET",))
def ping():
    log.debug("ping!")
    return jsonify({"message": "pong!", "status": "success"})


if __name__ == "__main__":
    app.run()

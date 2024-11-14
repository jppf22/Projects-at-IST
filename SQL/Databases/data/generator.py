import sys
sys.set_int_max_str_digits(0)

import copy
import random
import datetime
from datetime import datetime, timedelta

import math
from math import isclose

populate_file = "populate.sql"
appointments_file = "appointments.sql"

# ----------------------------------------------------------------------------------------------------------------------------------------

clinics = ["Clinica A","Clinica B","Clinica C","Clinica D","Clinica E"]

medicos_clinic_schedule = {}

for medico in range(200000001, 200000061):
    medicos_clinic_schedule[str(medico)] = ({'0': "", '1': "", '2': "", '3': "", '4': "", '5':"", '6':""}, [])

#medicos_clinics = [[] for x in range(200000001, 200000061)]

def generate_trabalha_data():
    trabalha_data = []

    # Determine which clinics each medico works at
    quantidade_clinicas = [2, 3, 4, 5]

    for medico in medicos_clinic_schedule:
        number_clinics = random.choices(quantidade_clinicas, weights=[20, 50, 20, 10], k=1)[0]
        clinics_possible = copy.deepcopy(clinics)
        for _ in range(number_clinics):
            clinica_escolhida = random.choice(clinics_possible)
            clinics_possible.remove(clinica_escolhida)
            medicos_clinic_schedule[medico][1].append([clinica_escolhida, 0])

    for day_of_the_week in range(7):
        for medico in medicos_clinic_schedule:
            medico_clinic_choices = copy.deepcopy(medicos_clinic_schedule[medico][1])
            medico_clinic_choices = sorted(medico_clinic_choices, key=lambda x: x[1])
            medicos_clinic_schedule[medico][0][str(day_of_the_week)] = medico_clinic_choices[0][0]

            for i in range(len(medicos_clinic_schedule[medico][1])):
                if medicos_clinic_schedule[medico][1][i][0] == medico_clinic_choices[0][0]:
                    medicos_clinic_schedule[medico][1][i][1] += 1
                    break

            trabalha_data.append((medico, medicos_clinic_schedule[medico][0][str(day_of_the_week)], str(day_of_the_week)))

    # Ensure each clinic has at least 8 medics per day
    clinics_verification = {}
    for clinic in clinics:
        clinics_verification[clinic] = {'0': 0, '1': 0, '2': 0, '3': 0, '4': 0, '5': 0, '6': 0}

    for medico in medicos_clinic_schedule:
        for day_of_the_week in medicos_clinic_schedule[medico][0]:
            clinic = medicos_clinic_schedule[medico][0][day_of_the_week]
            clinics_verification[clinic][day_of_the_week] += 1

    for day_of_the_week in range(7):
        for clinic in clinics:
            while clinics_verification[clinic][str(day_of_the_week)] < 8:
                # Find a medico to reassign to this clinic on this day
                for medico in medicos_clinic_schedule:
                    current_clinic = medicos_clinic_schedule[medico][0][str(day_of_the_week)]
                    if clinics_verification[current_clinic][str(day_of_the_week)] > 8:
                        medicos_clinic_schedule[medico][0][str(day_of_the_week)] = clinic
                        clinics_verification[current_clinic][str(day_of_the_week)] -= 1
                        clinics_verification[clinic][str(day_of_the_week)] += 1
                        break

    # Regenerate trabalha_data with the adjusted schedule
    trabalha_data = []
    for day_of_the_week in range(7):
        for medico in medicos_clinic_schedule:
            trabalha_data.append((medico, medicos_clinic_schedule[medico][0][str(day_of_the_week)], str(day_of_the_week)))

    return trabalha_data

         
def generate_trabalha_insert_statements(trabalha_data):
    insert_statements = []
    for trabalha in trabalha_data:
        insert_statement = "INSERT INTO trabalha (nif, nome, dia_da_semana) VALUES ('{}','{}','{}');".format(*trabalha)
        insert_statements.append(insert_statement)
    return insert_statements

trabalha_data = generate_trabalha_data()
#print(trabalha_data)
trabalha_insert_statements = generate_trabalha_insert_statements(trabalha_data)
#print(trabalha_insert_statements)


# ------------------------------------------------------------------------------------------------------------------------------------------
# generate random patient data

def get_zipcode(localidade):
    zipcodes = {
        "Sintra": (2700, 2799),
        "Cascais": (2750, 2799),
        "Lisboa": (1000, 1999),
        "Torres Vedras": (2560, 2599),
        "Mafra": (2640, 2659),
        "Oeiras": (2780, 2799),
        "Vila Franca de Xira": (2600, 2699),
        "Gondomar": (4420, 4599),
        "Porto": (4000, 4099),
        "Maia": (4470, 4499),
        "Trofa": (4785, 4799),
        "Vila Nova de Gaia": (4400, 4499),
        "Arganil": (3300, 3399),
        "Lousã": (3200, 3299),
        "Montemor-o-Velho": (3140, 3199),
        "Soure": (3130, 3199),
        "Palmela": (2950, 2999),
        "Setúbal": (2900, 2999),
        "Barreiro": (2830, 2849),
        "Montijo": (2870, 2899),
        "Grândola": (7570, 7599),
        "Seixal": (2840, 2859)
    }
    range_start, range_end = zipcodes[localidade]
    return f"{random.randint(range_start, range_end)}-{random.randint(100, 999)}"

def generate_patient_data():
    patients = []
    starting_ssn = 1
    for patient in range(5000):
        ssn = str(starting_ssn).zfill(11)
        nif = ''.join(random.choices('0123456789', k=9))
        nome = "Paciente " + str(patient)
        telefone = "93" + ''.join(random.choices('0123456789', k=7))
        distrito = random.choice(["Lisboa", "Porto", "Coimbra","Setúbal"])
        localidade = ""
        if distrito == "Lisboa":
            localidade = random.choice(["Sintra","Cascais","Lisboa","Torres Vedras","Mafra","Oeiras","Vila Franca de Xira"])
        elif distrito == "Porto":
            localidade = random.choice(["Gondomar","Porto","Maia","Trofa","Vila Nova de Gaia"])
        elif distrito == "Coimbra":
            localidade = random.choice(["Arganil","Lousã","Montemor-o-Velho","Soure"])
        elif distrito == "Setúbal":
            localidade = random.choice(["Palmela","Setúbal","Barreiro","Montijo","Grândola","Seixal"])

        zipcode = get_zipcode(localidade)
        morada = "Rua " + str(random.randint(1, 1000)) + ", " + zipcode + ", " + localidade + ", " + distrito
        data_nasc = str(random.randint(1950, 2024)) + '-' + str(random.randint(1, 12)).zfill(2) + '-' + str(random.randint(1, 28)).zfill(2)
        patients.append((ssn, nif, nome, telefone, morada, data_nasc))
        starting_ssn = starting_ssn+1

    return patients

# generate patient SQL INSERT statements
def generate_patient_insert_statements(patients):
    insert_statements = []
    for patient in patients:
        insert_statement = "INSERT INTO paciente (ssn, nif, nome, telefone, morada, data_nasc) VALUES ('{}', '{}', '{}', '{}', '{}', '{}');".format(*patient)
        insert_statements.append(insert_statement)
    return insert_statements


patients_data = generate_patient_data()
patient_insert_statements = generate_patient_insert_statements(patients_data)

# ----------------------------------------------------------------------------------------------------------------------------------------------------------


clinic_schedule = {}

def create_clinic_schedule():
    for clinic in clinics:
          clinic_schedule[clinic] = {}
          for year in [2023, 2024]:
            for month in range(1, 13):
                num_days = 31 if month in [1, 3, 5, 7, 8, 10, 12] else 30 if month in [4, 6, 9, 11] else 28
                if month == 2 and year % 4 == 0:
                    num_days = 29  # Leap year
                
                for day in range(1, num_days + 1):
                    clinic_schedule[clinic][str(datetime(year,month,day).date())] = 0

create_clinic_schedule()
#print(clinic_schedule)

medico_appointments = {}

for medico in range(200000001, 200000061):
    medico_appointments[str(medico)] = {}
    '''
    for weekday in range(7):
        medico_appointments[str(medico)][str(weekday)] = []
    '''
    for year in [2023, 2024]:
        for month in range(1, 13):
            num_days = 31 if month in [1, 3, 5, 7, 8, 10, 12] else 30 if month in [4, 6, 9, 11] else 28
            if month == 2 and year % 4 == 0:
                num_days = 29  # Leap year
            
            for day in range(1, num_days + 1):
                medico_appointments[str(medico)][str(datetime(year,month,day).date())] = []

#print(medicos)

# Generate consultations for each day in 2023 and 2024
def generate_consultation_records():
    consultation_records = []
    sns_code = 0
    current_client = 1
    have_all_clients_been_reached = False
    
    medicos_to_be_assigned = { str(x): 0 for x in range(200000001, 200000061)}

    for year in [2023, 2024]:
        for month in range(1, 13):
            num_days = 31 if month in [1, 3, 5, 7, 8, 10, 12] else 30 if month in [4, 6, 9, 11] else 28
            if month == 2 and year % 4 == 0:
                num_days = 29  # Leap year
            
            for day in range(1, num_days + 1):
                date = datetime(year, month, day)
                weekday = (date.weekday() + 1) % 7
                start_time = datetime.strptime("08:00", "%H:%M")
                lunch_start = datetime.strptime("13:00", "%H:%M")
                lunch_end = datetime.strptime("14:00", "%H:%M")
                end_time = datetime.strptime("19:00", "%H:%M")

                for clinic in clinics:

                    while clinic_schedule[clinic][str(date.date())] < 20:
                        medico_assigned = False

                        medicos_range = list(medicos_to_be_assigned.keys())
                        medicos_range = sorted(medicos_range, key=lambda x: medicos_to_be_assigned[x])
                        medicos_range = list(map(lambda x: int(x),medicos_range))
                        #print(medicos_range)

                        for medico in medicos_range:
                            medico = str(medico)
                            if clinic != medicos_clinic_schedule[medico][0][str(weekday)]:
                                continue

                            current_time = start_time

                            while current_time < end_time:
                                if current_time == lunch_start:
                                    current_time = lunch_end
                                
                                if current_time in medico_appointments[medico][str(datetime(year,month,day).date())]:
                                    current_time += timedelta(minutes=30)
                                    continue
                                
                                medico_appointments[medico][str(datetime(year,month,day).date())].append(current_time)
                                medicos_to_be_assigned[medico] += 1

                                consultation_records.append(
                                    (
                                        str(current_client).zfill(11),
                                        medico,
                                        clinic,
                                        str(date.date()),
                                        str(current_time.strftime("%H:%M")),
                                        str(sns_code).zfill(12),
                                    )
                                )

                                if current_client == 5000:
                                    have_all_clients_been_reached = True
                                    current_client = 1
                                else:
                                    current_client += 1

                                sns_code += 1
                                clinic_schedule[clinic][str(date.date())] += 1
                                medico_assigned = True
                                break
                            
                            if medico_assigned:
                                break

                        if not medico_assigned:
                            break

    return consultation_records

def generate_consulta_insert_statements(consultation_records):
    insert_statements = []
    for consulta in consultation_records:
        insert_statement = "INSERT INTO consulta (ssn, nif, nome, data, hora, codigo_sns) VALUES ('{}', '{}', '{}', '{}', '{}', '{}');".format(*consulta)
        insert_statements.append(insert_statement)
    return insert_statements

consulta_data = generate_consultation_records()
consulta_insert_statements = generate_consulta_insert_statements(consulta_data)


#print(clinic_schedule)
#print(medico_appointments)
#print(consulta_data)
# ----------------------------------------------------------------------------------------------------------------------------------------------------------
medicamentos = [
    "Paracetamol",
    "Ibuprofeno",
    "Omeprazol",
    "Amoxicilina",
    "Cetirizina",
    "Clonazepam",
    "Enalapril",
    "Losartana",
    "Metformina",
    "Simvastatina",
    "Atorvastatina",
    "Furosemida",
    "Loratadina",
    "Diazepam",
    "Dexametasona",
    "Pantoprazol",
    "Fluoxetina",
    "Ranitidina",
    "Levotiroxina",
    "Alprazolam"
]


def generate_receita_data():
    receita_data = []
    consulta_counter = 0
    consulta_max = len(consulta_data)

    for consulta in consulta_data:

        if math.isclose(float(consulta_counter)/consulta_max, 0.8): #80% das consultas tem receita
            break
        
        medicamento_amount_possible = [1,2,3,4,5,6]

        medicamento_amount = random.choices(medicamento_amount_possible,weights=[60,20,10,5,3,2],k=1)[0] #Cada consulta pode ter 1 a 6 medicamentos diferentes receitados, a escolha é weighted para ser mais realista
        possiveis_medicamentos = copy.deepcopy(medicamentos)
        
        for medicamento_num in range(medicamento_amount):
            
            #Escolhemos um medicamento dos possiveis
            medicamento_receita = random.choice(possiveis_medicamentos)
            possiveis_medicamentos.remove(medicamento_receita)

            #Cada medicamento pode ter quantidade entre 1 e 3
            quantidade_medicamento = random.randint(1,3) 

            receita_data.append((consulta[5], medicamento_receita, str(quantidade_medicamento)))
        
        #O count está de fora porque uma consulta pode ter mais de um medicamento associado!
        consulta_counter += 1
    
    return receita_data

def generate_receita_insert_statements(receita_data):
    insert_statements = []
    for receita in receita_data:
        insert_statement = "INSERT INTO receita (codigo_sns, medicamento, quantidade) VALUES ('{}', '{}', '{}');".format(*receita)
        insert_statements.append(insert_statement)
    return insert_statements

#print(generate_receita_data())
receita_data = generate_receita_data()
receita_insert_statements = generate_receita_insert_statements(receita_data)

#for i in receita_insert_statements:
#    print(i)


# ----------------------------------------------------------------------------------------------------------------------------------------------------------



parametros_sintoma = [
    "Dor de cabeça",
    "Febre",
    "Tosse",
    "Dor de garganta",
    "Dor abdominal",
    "Náusea",
    "Vômito",
    "Falta de ar",
    "Dor no peito",
    "Cansaço",
    "Tontura",
    "Calafrios",
    "Coriza",
    "Congestão nasal",
    "Perda de apetite",
    "Perda de olfato",
    "Perda de paladar",
    "Diarreia",
    "Prisão de ventre",
    "Erupção cutânea",
    "Coceira",
    "Olhos vermelhos",
    "Dor nas articulações",
    "Inchaço",
    "Sudorese",
    "Palpitações",
    "Fraqueza",
    "Confusão mental",
    "Desmaio",
    "Manchas na pele",
    "Rouquidão",
    "Falta de coordenação",
    "Tremores",
    "Visão turva",
    "Secreção ocular",
    "Dor de dente",
    "Dor lombar",
    "Perda de equilíbrio",
    "Aftas",
    "Sangramento nasal",
    "Formigamento",
    "Dor nos ouvidos",
    "Sensibilidade à luz",
    "Zumbido no ouvido",
    "Hematomas",
    "Dor na panturrilha",
    "Incontinência urinária",
    "Ardor ao urinar",
    "Inchaço dos linfonodos"
]

parametros_metrica = [
    ("Temperatura corporal", 42.0),
    ("Pressão arterial sistólica", 180.0),
    ("Pressão arterial diastólica", 120.0),
    ("Frequência cardíaca", 200.0),
    ("Nível de glicose", 300.0),
    ("Saturação de oxigênio", 100.0),
    ("Índice de massa corporal (IMC)", 50.0),
    ("Altura", 2.5),
    ("Peso", 200.0),
    ("Circunferência abdominal", 150.0),
    ("Taxa de filtração glomerular", 120.0),
    ("Nível de colesterol total", 300.0),
    ("Nível de HDL", 100.0),
    ("Nível de LDL", 200.0),
    ("Triglicerídeos", 400.0),
    ("Volume expiratório forçado no primeiro segundo (VEF1)", 8.0),
    ("Capacidade vital forçada (CVF)", 8.0),
    ("Taxa de sedimentação de eritrócitos", 50.0),
    ("Nível de hemoglobina", 20.0),
    ("Contagem de leucócitos", 20000.0)
]

def generate_observacao_data():
    observacao_data = []
    for consulta in consulta_data:
        consulta = list(consulta)
        
        consulta[4] = consulta[4] + ":00"

        possible_sintoma_amount = [1,2,3,4,5]
        sintoma_amount = random.choices(possible_sintoma_amount,weights=[60,20,15,4,1],k=1)[0]

        possiveis_sintomas = copy.deepcopy(parametros_sintoma)
        for sintoma_index in range(sintoma_amount):
            sintoma = random.choice(possiveis_sintomas)
            possiveis_sintomas.remove(sintoma)
            observacao_data.append((sintoma,"NULL",consulta[0],consulta[3],consulta[4]))


        possible_metrica_amount = [0,1,2,3]
        metrica_amount = random.choices(possible_metrica_amount,weights=[60,20,15,5],k=1)[0]

        possiveis_metricas = copy.deepcopy(parametros_metrica)

        for metrica_index in range(metrica_amount):
            metrica = random.choice(possiveis_metricas)
            possiveis_metricas.remove(metrica)

            metrica_nome = metrica[0]
            metrica_amount = random.uniform(0.0,metrica[1])

            observacao_data.append((metrica_nome,str(metrica_amount),consulta[0],consulta[3],consulta[4]))
    
    return observacao_data



def generate_observacao_insert_statements(observecao_data):

    insert_statements = []
    for observacao in observacao_data:
        insert_statement = \
        f"""INSERT INTO observacao (id, parametro, valor)
        SELECT id, '{observacao[0]}', {observacao[1]}
        FROM consulta
        WHERE ssn = '{observacao[2]}' AND data = '{observacao[3]}' AND hora = '{observacao[4]}';
        """
        insert_statements.append(insert_statement)

    return insert_statements

observacao_data = generate_observacao_data()
observacao_insert_statements = generate_observacao_insert_statements(observacao_data)
#print(observacao_insert_statements)


# ----------------------------------------------------------------------------------------------------------------------------------------------------------

# EXTRA INSERTS TO ENSURE OUTPUT IN 5.2 (due to random nature of generation may not always give an output)

extra_insert_statements = [
    """
    INSERT INTO consulta(ssn, nif, nome, data, hora, codigo_sns) 
        VALUES 
        ('00000001000', '200000023', 'Clinica D', '2023-05-01', '17:00', '100000000000'),
        ('00000001000', '200000023', 'Clinica B', '2023-06-01', '17:00', '100000000001'),
        ('00000001000', '200000023', 'Clinica B', '2023-07-01', '17:00', '100000000002'),
        ('00000001000', '200000023', 'Clinica B', '2023-08-01', '17:00', '100000000003'),
        ('00000001000', '200000023', 'Clinica D', '2023-09-01', '17:00', '100000000004'),
        ('00000001000', '200000023', 'Clinica B', '2023-10-01', '17:00', '100000000005'),
        ('00000001000', '200000023', 'Clinica D', '2023-11-01', '17:00', '100000000006'),
        ('00000001000', '200000023', 'Clinica D', '2023-12-01', '17:00', '100000000007'),
        ('00000001000', '200000023', 'Clinica D', '2024-01-01', '17:00', '100000000008'),
        ('00000001000', '200000023', 'Clinica B', '2024-02-01', '17:00', '100000000009'),
        ('00000001000', '200000023', 'Clinica D', '2024-03-01', '17:00', '100000000010'),
        ('00000001000', '200000023', 'Clinica D', '2024-04-01', '17:00', '100000000011'),
        ('00000001000', '200000023', 'Clinica D', '2024-05-01', '17:00', '100000000012'),
        ('00000001000', '200000023', 'Clinica B', '2024-06-01', '17:00', '100000000013');
    """,
    """
    INSERT INTO receita (codigo_sns, medicamento, quantidade) 
        VALUES 
        ('100000000000', 'Atorvastatina', '1'),
        ('100000000001', 'Atorvastatina', '1'),
        ('100000000002', 'Atorvastatina', '1'),
        ('100000000003', 'Atorvastatina', '1'),
        ('100000000004', 'Atorvastatina', '1'),
        ('100000000005', 'Atorvastatina', '1'),
        ('100000000006', 'Atorvastatina', '1'),
        ('100000000007', 'Atorvastatina', '1'),
        ('100000000008', 'Atorvastatina', '1'),
        ('100000000009', 'Atorvastatina', '1'),
        ('100000000010', 'Atorvastatina', '1'),
        ('100000000011', 'Atorvastatina', '1'),
        ('100000000012', 'Atorvastatina', '1'),
        ('100000000013', 'Atorvastatina', '1');
    """
    ]

# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# WRITE SQL statements to file


with open(populate_file, 'a+') as f:
    for statement in trabalha_insert_statements:
        f.write(statement + '\n')

    for statement in patient_insert_statements:
       f.write(statement + '\n')
    
    for statement in consulta_insert_statements:
        f.write(statement + '\n')
        f.flush()

    for statement in receita_insert_statements:
       f.write(statement + '\n')

    for statement in observacao_insert_statements:
        f.write(statement + '\n')

    for statement in extra_insert_statements:
        f.write(statement + '\n')

    f.close()

# -----------------------------------------------------------------------------------------------------------------------------------------------------------

def generate_horarios_data():

    horarios_data = []
    medicos_range = [str(x) for x in range(200000001, 200000061)]

    for year in [2024]:
        for month in range(5,13): # á data do development era mês 5
            num_days = 31 if month in [1, 3, 5, 7, 8, 10, 12] else 30 if month in [4, 6, 9, 11] else 28
            if month == 2 and year % 4 == 0:
                num_days = 29  # Leap year

            for day in range(1, num_days + 1):
                date = datetime(year, month, day)
                weekday = (date.weekday() + 1) % 7
                start_time = datetime.strptime("08:00", "%H:%M")
                lunch_start = datetime.strptime("13:00", "%H:%M")
                lunch_end = datetime.strptime("14:00", "%H:%M")
                end_time = datetime.strptime("19:00", "%H:%M")

                for medico in medicos_range:

                    current_time = start_time
                    
                    while current_time < end_time:
                        if current_time == lunch_start:
                            current_time = lunch_end
                        
                        if current_time in medico_appointments[medico][str(datetime(year,month,day).date())]:
                                    current_time += timedelta(minutes=30)
                                    continue
                        
                        horarios_data.append(
                            (
                                medico,
                                medicos_clinic_schedule[medico][0][str(weekday)],
                                str(date.date()),
                                str(current_time.strftime("%H:%M")),
                            )
                        )

                        current_time += timedelta(minutes=30)
    
    return horarios_data


def generate_horario_insert_statemenents(horarios_data):
    insert_statements = []
    for slot in horarios_data:
        insert_statement = "INSERT INTO horarios (nif, nome, data, hora) VALUES('{}','{}','{}','{}');" .format(*slot)
        insert_statements.append(insert_statement)
    return insert_statements                            

horarios_data = generate_horarios_data()
horarios_insert_statements = generate_horario_insert_statemenents(horarios_data)

is_every_slot_really_free = True
for slot in horarios_data:
    if datetime.strptime(slot[3],"%H:%M") in medico_appointments[slot[0]][slot[2]]:
        is_every_slot_really_free = False
print(is_every_slot_really_free)

extra_insert_statements_remove = [
    """
    DELETE FROM horarios 
        WHERE 
            (nif='200000023' AND nome = 'Clinica D' AND data = '2023-05-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica B' AND data = '2023-06-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica B' AND data = '2023-07-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica B' AND data = '2023-08-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica D' AND data = '2023-09-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica B' AND data = '2023-10-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica D' AND data = '2023-11-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica D' AND data = '2023-12-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica D' AND data = '2024-01-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica B' AND data = '2024-02-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica D' AND data = '2024-03-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica D' AND data = '2024-04-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica D' AND data = '2024-05-01' AND hora = '17:00') OR
            (nif='200000023' AND nome = 'Clinica B' AND data = '2024-06-01' AND hora = '17:00');
    """
]

with open(appointments_file, 'a+') as f:

    for statement in horarios_insert_statements:
        f.write(statement + '\n')

    for statement in extra_insert_statements_remove:
        f.write(statement + '\n')

    f.close()
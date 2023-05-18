% 106022 Joao Fernandes
:- set_prolog_flag(answer_write_options, [max_depth(0)]).
:- ['dados.pl'],['keywords.pl'].

/*
Codigo 
*/

% Predicados Auxiliares -------------------------------------------------------------

% adiciona_semestre/2 - adiciona o semestre/s na lista dos periodos dada
adiciona_semestre(ListaPeriodos,ListaPeriodosT) :-
    (member(p1,ListaPeriodos);member(p2,ListaPeriodos)),
    (member(p3,ListaPeriodos);member(p4,ListaPeriodos)),
    append(ListaPeriodos,[p1_2,p3_4],ListaPeriodosT),
    !.

adiciona_semestre(ListaPeriodos,ListaPeriodosT) :-
    (member(p1,ListaPeriodos);member(p2,ListaPeriodos)),
    \+(member(p3,ListaPeriodos);member(p4,ListaPeriodos)),
    append(ListaPeriodos,[p1_2],ListaPeriodosT),
    !.   

adiciona_semestre(ListaPeriodos,ListaPeriodosT) :-
    \+(member(p1,ListaPeriodos);member(p2,ListaPeriodos)),
    (member(p3,ListaPeriodos);member(p4,ListaPeriodos)),
    append(ListaPeriodos,[p3_4],ListaPeriodosT),
    !.

% lista_cursos/1 - devolve uma lista com as licenciaturas e mestrados 
lista_cursos(Lista) :-
    licenciaturas(tagus,Lista_L),
    mestrados(tagus,Lista_M),
    append(Lista_L,Lista_M,Lista).

% lista_periodos/1 - devolve uma lista com os todos os periodos de um ano
lista_periodos(Lista) :-
    Lista = [p1,p2,p3,p4].

%lista_anos/1 - devolve uma lista com os anos maximos que um curso tem
lista_anos(Lista) :-
    Lista = [1,2,3].

%lista_dia_semana/1 - devolve uma lista com os dias da semana
lista_dia_semana(Lista) :-
    Lista = [segunda-feira,terca-feira,quarta-feira,quinta-feira,sexta-feira].

% 1 -------------------------------------------------------------------------------

%eventosSemSalas/1 - devolve uma lista com todos os eventos sem sala da base de dados
eventosSemSalas(EventosSemSala) :-
    findall(ID,evento(ID,_,_,_,semSala),EventosSemSala_Unsorted),
    sort(EventosSemSala_Unsorted,EventosSemSala).

%eventosSemSalasDiaSemana/2 - devolve uma lista com todos os eventos sem sala no dia da semana dado    
eventosSemSalasDiaSemana(DiaDaSemana, EventosSemSala) :-
    eventosSemSalas(EventosSemSala_todos),
    findall(ID,(member(ID, EventosSemSala_todos),horario(ID, DiaDaSemana,_,_,_,_)),EventosSemSala_Unsorted),
    sort(EventosSemSala_Unsorted,EventosSemSala).

%eventosSemSalasPeriodo/2 - devolve uma lista com todos os eventos sem sala no periodo dado
eventosSemSalasPeriodo([],[]) :- !.
eventosSemSalasPeriodo(ListaPeriodos, EventosSemSala) :-
    eventosSemSalas(EventosSemSala_todos),
    adiciona_semestre(ListaPeriodos,ListaPeriodosT),
    findall(ID,(member(ID, EventosSemSala_todos),member(Periodo,ListaPeriodosT),horario(ID,_,_,_,_,Periodo)),EventosSemSala_Unsorted),
    sort(EventosSemSala_Unsorted,EventosSemSala).


% 2 -------------------------------------------------------------------------------

%organizaEventos/3 - EventosNoPeriodo e a lista formada pelos eventos de ListaEventos que ocorrem no Periodo dado
organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) :-
    adiciona_semestre([Periodo],Periodo_e_Semestre),
    organizaEventos(ListaEventos,Periodo_e_Semestre,EventosNoPeriodo,[]),
    !.

organizaEventos([],_,EventosNoPeriodo,EventosNoPeriodo) :- !.

organizaEventos([C|ListaEventos],Periodo_e_Semestre,EventosNoPeriodo,EventosAux) :-
    member(P,Periodo_e_Semestre),
    horario(C,_,_,_,_,P),
    \+(member(C,EventosAux)),
    sort([C|EventosAux], EventosAux_Plus),
    !,
    organizaEventos(ListaEventos,Periodo_e_Semestre,EventosNoPeriodo,EventosAux_Plus).

organizaEventos([_|ListaEventos],Periodo_e_Semestre,EventosNoPeriodo,EventosAux) :-
    organizaEventos(ListaEventos,Periodo_e_Semestre,EventosNoPeriodo,EventosAux).

%eventosMenoresQue/2 - ListaEventosMenoresQue e a lista formada pelos eventos da base de dados que tem duracao menor ou igual que Duracao
eventosMenoresQue(Duracao,ListaEventosMenoresQue) :-
    findall(ID,(horario(ID,_,_,_,Duracao_2,_),Duracao_2 =< Duracao),ListaEventosMenoresQue_Unsorted),
    sort(ListaEventosMenoresQue_Unsorted,ListaEventosMenoresQue).

%eventosMenoresQueBool - verdade caso o evento do ID dado tenha duracao do evento dado seja menor ou igual a Duracao
eventosMenoresQueBool(ID, Duracao) :-
    horario(ID,_,_,_,Duracao_2,_),
    Duracao_2 =< Duracao.

%procuraDisciplinas/2 - ListaDisciplinas e a lista ordenada alfabeticamente das disciplinas do Curso dado
procuraDisciplinas(Curso, ListaDisciplinas) :-
    findall(Nome,(turno(ID,Curso,_,_),evento(ID,Nome,_,_,_)), ListaDisciplinas_Unsorted),
    sort(ListaDisciplinas_Unsorted,ListaDisciplinas),
    !.

/* organizaDisciplinas/3 - Semestres e a lista com duas listas em que a primeira corresponde as disciplinas da ListaDisciplinas que sao do Curso 
e ocorrem no primeiro semestre, e o mesmo para a segunda lista e o segundo semestre */
organizaDisciplinas(ListaDisciplinas, Curso, Semestres) :-
    procuraDisciplinas(Curso,ListaDisciplinas_doCurso),
    organizaDisciplinas(ListaDisciplinas,Curso,ListaDisciplinas_doCurso,Semestres,[],[]),
    !.

organizaDisciplinas([],_,_,Semestres,Primeiro,Segundo) :-
    Semestres = [Primeiro,Segundo],
    !.

organizaDisciplinas([C|ListaDisciplinas],Curso,ListaDisciplinas_doCurso,Semestres,Primeiro,Segundo) :-
    member(C,ListaDisciplinas_doCurso),
    member(Periodo, [p1,p2,p1_2]),
    evento(ID,C,_,_,_),
    horario(ID,_,_,_,_,Periodo),
    append(Primeiro,[C],Primeiro_plus),
    !,
    organizaDisciplinas(ListaDisciplinas,Curso,ListaDisciplinas_doCurso,Semestres,Primeiro_plus,Segundo).

organizaDisciplinas([C|ListaDisciplinas],Curso,ListaDisciplinas_doCurso,Semestres,Primeiro,Segundo) :-
    member(C,ListaDisciplinas_doCurso),
    member(Periodo, [p3,p4,p3_4]),
    evento(ID,C,_,_,_),
    horario(ID,_,_,_,_,Periodo),
    append(Segundo,[C],Segundo_plus),
    !,
    organizaDisciplinas(ListaDisciplinas,Curso,ListaDisciplinas_doCurso,Semestres,Primeiro,Segundo_plus).

%horasCurso/4 - TotalHoras e a soma das horas associadas aos eventos do Curso no Ano e no Periodo
horasCurso(Periodo, Curso, Ano, TotalHoras) :-
    lista_cursos(Cursos),
    member(Curso,Cursos),
    adiciona_semestre([Periodo],Periodo_e_Semestre),
    findall(ID,turno(ID,Curso,Ano,_),EventosDiferentes_Unsorted),
    sort(EventosDiferentes_Unsorted,EventosDiferentes),
    maplist(horas_evento(Periodo_e_Semestre),EventosDiferentes,Horas),
    sum_list(Horas,TotalHoras),
    !.

%horas_evento/3 - Predicado Auxiliar a horasCurso onde Hora corresponde as horas do evento correspondente ao ID
horas_evento(Periodo_e_Semestre,ID,Hora) :-
    horario(ID,_,_,_,Duracao,Periodo),
    member(Periodo,Periodo_e_Semestre),
    Hora is Duracao,
    !.

horas_evento(_,_,Hora) :-
    Hora is 0.

%
/* evolucaoHorasCurso/2 - Evolucao corresponde a uma lista de tuplos (Ano,Periodo,Horas) em que Horas e o total de horas associadas ao curso no Ano e no Periodo
para todos os anos e periodos do Curso dado, ordenada de forma crescente*/
evolucaoHorasCurso(Curso, Evolucao) :- 
    lista_cursos(Cursos),
    member(Curso,Cursos),
    lista_anos(Anos),
    lista_periodos(Periodos),
    setof((Ano,Periodo,Horas),Ano^Periodo^Horas^(member(Ano,Anos),member(Periodo,Periodos),horasCurso(Periodo,Curso,Ano,Horas)),Evolucao),
    !.

% 3 -------------------------------------------------------------------------------

/* ocupaSlot/5 - Horas corresponde ao numero de horas sobrepostas entre o evento que comeca a HoraInicioEvento e termina a HoraFimEvento 
e o slot que comeca a HoraInicioDada e termina a HoraFimDada */
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
    max_list([HoraInicioDada,HoraInicioEvento],Begin),
    min_list([HoraFimDada,HoraFimEvento], End),
    Horas is End-Begin,
    Horas >= 0.

% numHorasOcupadas/6 - SomaHoras corresponde ao numero de horas ocupadas nas salas do TipoSala dado no dia DiaSemana e no Periodo entre HoraInicio e HoraFim
numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :- 
    salas(TipoSala, Salas),
    adiciona_semestre([Periodo],Periodo_e_Semestre),
    findall(Horas,(horario(ID,DiaSemana,HI,HF,_,Periodo_2),evento(ID,_,_,_,Sala),member(Sala,Salas),
    member(Periodo_2,Periodo_e_Semestre),ocupaSlot(HoraInicio,HoraFim,HI,HF,Horas)),Lista_Horas),
    sum_list(Lista_Horas,SomaHoras).

%ocupacaoMax/4 - Max corresponde ao numero de horas possiveis a ser ocupadas em salas do TipoSala entre HoraInicio e HoraFim
ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) :- 
    salas(TipoSala,Salas),
    length(Salas, Num_Salas),
    Max is Num_Salas * (HoraFim - HoraInicio).

%percentagem/3 - Percentagem corresponde a divisao de SomaHoras por Max
percentagem(SomaHoras, Max, Percentagem) :-
    Percentagem is (SomaHoras / Max)*100.

%
/* ocupacaoCritica/4 - Resultados corresponde a lista ordenada de tuplos casosCriticos(DiaSemana,TipoSala,Percentagem) 
em que Percentagem corresponde a taxa de ocupacao entre HoraInicio e HoraFim para os dias da semana e periodos se esta estiver acima de um dado Treshold.*/
ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados) :-
    lista_periodos(Periodos),
    lista_dia_semana(Semana),
    findall(casosCriticos(DiaSemana,TipoSala,Percentagem_arrendodada),
    (member(Periodo,Periodos),member(DiaSemana,Semana), 
    numHorasOcupadas(Periodo,TipoSala,DiaSemana,HoraInicio,HoraFim,SomaHoras),
    ocupacaoMax(TipoSala,HoraInicio,HoraFim,Max),percentagem(SomaHoras,Max,Percentagem),
    Percentagem > Threshold, Percentagem_arrendodada is ceiling(Percentagem)),Resultados_semSort),
    sort(Resultados_semSort,Resultados).

% 4 -------------------------------------------------------------------------------

%
/* ocupacaoMesa/3 - OcupacaoMesa corresponde a uma lista representativa da mesa onde estao sentadas as pessoas com os nomes da ListaNomes 
cumprindo as restricoes dadas vindas da ListaRestricoes */
cab1(X,L) :- L = [_,_,_,X,_,_,_,_].
cab2(X,L) :- L = [_,_,_,_,X,_,_,_].
honra(X,Y,L) :- L = [_,_,_,X,_,Y,_,_];
    L = [_,_,Y,_,X,_,_,_].

lado(X,Y,L):-
    \+cab1(X,L),\+cab2(X,L),\+cab1(Y,L),\+cab2(Y,L),
    nth1(Ind_X,L,X),
    nth1(Ind_Y,L,Y),
    abs(Ind_X-Ind_Y) =:= 1.
naoLado(X,Y,L) :- 
    nth1(Ind_X,L,X),
    nth1(Ind_Y,L,Y),
    abs(Ind_X-Ind_Y) =\= 1.
frente(X,Y,L) :- \+cab1(X,L),\+cab2(X,L),\+cab1(Y,L),\+cab2(Y,L),
    nth1(Ind_X,L,X),
    nth1(Ind_Y,L,Y),
    abs(Ind_X-Ind_Y) =:= 5.
naoFrente(X,Y,L) :- 
    nth1(Ind_X,L,X),
    nth1(Ind_Y,L,Y),
    abs(Ind_X-Ind_Y) =\= 5.

verdade_para_restricoes([],_):-!.
verdade_para_restricoes([Cond|ListaRestricoes],L) :-
    Cond=..[N|Args],
    append(Args,[L],Args_comL),
    Teste=..[N|Args_comL],
    Teste,
    verdade_para_restricoes(ListaRestricoes,L).

ocupacaoMesa(ListaNomes,ListaRestricoes,OcupacaoMesa) :-
    OcupacaoMesa = [[X1,X2,X3],[X4,X5],[X6,X7,X8]],
    L = [X1,X2,X3,X4,X5,X6,X7,X8],
    permutation(ListaNomes, L),
    verdade_para_restricoes(ListaRestricoes,L).

    






    
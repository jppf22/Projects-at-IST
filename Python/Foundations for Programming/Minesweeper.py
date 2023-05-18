

# TAD Gerador
# Chosen representation - type: list -> [int,int] = [bits,seed]

def is_valid_state(bits,seed):
    if(bits == 32):
        return (seed <= 0xFFFFFFFF)
    elif(bits == 64):
        return (seed <= 0xFFFFFFFFFFFFFFFF)

def cria_gerador(bits,seed):
    '''
    Returns a xorshift generator with dimension equal to parameter bits

    bits -> int
    seed -> int
    return -> gerador
    '''
    if(type(bits) != int or bits not in (32,64) or type(seed) != int or seed <= 0 or not(is_valid_state(bits,seed))):
        raise ValueError("cria_gerador: argumentos invalidos")

    return [bits,seed]

def cria_copia_gerador(generator):
    '''
    Returns a copy of the given generator

    generator -> gerador
    return -> gerador
    '''
    return generator.copy()

def obtem_estado(generator):
    '''
    Returns the state of the seed of the given generator

    generator -> gerador
    return -> int
    '''
    return generator[1]

def define_estado(generator,state):
    '''
    Assigns and returns a state to the seed of the given generator
    
    generator -> gerador
    state -> int
    return -> int
    '''
    generator[1] = state
    return state

def atualiza_estado(generator):
    '''
    Updates the state of the seed with the xorshift algorithm to generator random numbers

    generator -> gerador
    return -> gerador
    '''

    if generator[0] == 32:
        generator[1] ^= (generator[1] << 13) & 0xFFFFFFFF
        generator[1] ^= (generator[1] >> 17) & 0xFFFFFFFF
        generator[1] ^= (generator[1] << 5) & 0xFFFFFFFF
    elif(generator[0] == 64):
        generator[1] ^= (generator[1] << 13) & 0xFFFFFFFFFFFFFFFF
        generator[1] ^= (generator[1] >> 7) & 0xFFFFFFFFFFFFFFFF
        generator[1] ^= (generator[1] << 17) & 0xFFFFFFFFFFFFFFFF
    return generator[1]

def eh_gerador(arg):
    '''
    Returns true if the given argument correctly represents the ADT gerador

    arg -> universal
    return -> bool
    '''
    return (type(arg) == list and len(arg) == 2 and type(arg[0]) == int and arg[0] in (32,64) and type(arg[1]) == int and 0 < arg[1] and is_valid_state(arg[0],arg[1]))

def geradores_iguais(gene1,gene2):
    '''
    Returns true if both given generators are equal

    gene1,gene2 -> gerador
    return -> bool
    '''
    return (eh_gerador(gene1) and eh_gerador(gene2) and gene1[0] == gene2[0] and gene1[1] == gene2[1])

def gerador_para_str(generator):
    '''
    Returns the str representation of the given generator. Format: "xorshift{bits}(s = {state})" where bits is the dimension and state the current state of the seed
    
    generator -> gerador
    return -> str
    '''
    return "xorshift" + str(generator[0]) + "(s=" + str(generator[1]) + ")"

# Funções alto-nível para Gerador 

def gera_numero_aleatorio(generator,max):
    '''
    Returns a random number between 1 and max

    generator -> gerador
    max -> int
    return -> int
    '''
    atualiza_estado(generator)
    return 1 + (obtem_estado(generator) % max)


def gera_carater_aleatorio(generator,max):
    '''
    Returns a random character between 'A' and the uppercase character max

    generator -> gerador
    max -> str
    return -> str
    '''
    atualiza_estado(generator)
    #Creates a string using .join() on an iterable made up of the characters 
    #between 'A' and the max char, including these.
    between_A_max = ''.join((chr(x) for x in range(ord('A'),ord(max)+1))) 

    return between_A_max[obtem_estado(generator) % len(between_A_max)]



# --------------------------------------------------

# TAD Coordenada -- imutable datatype!
# Chosen representation: type: tuple -> (str,int) = (col,lin)

def cria_coordenada(col,lin):
    '''
    Returns a coordinate tuple where the first value is a str representing the column and the second a int representing the line

    col -> str
    lin -> int
    return -> coordenada
    '''
    if(type(col) != str or len(col) != 1 or type(lin) != int or not('A' <= col <= 'Z') or not(1 <= lin <= 99)):
        raise ValueError("cria_coordenada: argumentos invalidos")

    return (col,lin)

def obtem_coluna(coordinate):
    '''
    Returns the column value of the given coordinate

    coordinate -> coordenada
    return -> str
    '''
    return coordinate[0]

def obtem_linha(coordinate):
    '''
    Returns the line value of the given coordinate

    coordinate -> coordenada
    return -> int
    '''
    return coordinate[1]

def eh_coordenada(arg):
    '''
    Returns True if the given argument correctly represents a coordinate,
    that is, if it follows the following representation: (col,lin) where col is a string and lin an int

    arg -> universal
    return -> bool
    '''
    return (type(arg) == tuple and len(arg) == 2 and type(arg[0]) == str and len(arg[0]) == 1 and type(arg[1]) == int and ('A' <= arg[0] <= 'Z') and (1 <= arg[1] <= 99))

def coordenadas_iguais(c1,c2): 
    '''
    Returns True if both coordinates are equal

    c1,c2 -> coordenada
    return -> bool
    '''
    return (eh_coordenada(c1) and eh_coordenada(c2) and c1 == c2)

def coordenada_para_str(coordinate):
    '''
    Returns a string that represents the coordinate in the format: "(col)(lin)" or "(col)0(lin)", if lin is only 1 digit

    coordinate -> coordenada
    return -> str
    '''
    if(coordinate[1] < 10):
        return coordinate[0] + "0" + str(coordinate[1])
    else:
        return coordinate[0] + str(coordinate[1])


def str_para_coordenada(c_as_text):
    '''
    Returns the coordinate represented by the given string
    
    c_as_text -> str
    return -> coordenada
    '''
    if(c_as_text[1] == '0'):
        return (c_as_text[0],int(c_as_text[2]))
    else:
        return (c_as_text[0],int(c_as_text[1]+c_as_text[2]))

# Funções alto nível para Coordenada

def obtem_coordenadas_vizinhas(coordinate):
    '''
    Returns a tuple containing the neighbour coordinates to the given coordinate, 
    starting in the upper-left diagonal position and iterating clockwise  

    coordinate -> coordenada
    return -> tuple(coordenada) 
    '''

    def sumCol(amount):
        return chr(ord(this_col)+amount)

    this_lin,this_col = obtem_linha(coordinate),obtem_coluna(coordinate)

    '''
    The values in the tuples represent the differences in the given coordinate values and the neighbour coordinate values
    Example: We start with the upper-left diagonal position so first pair has a line and column difference of -1
    since it is one line above and one column before compared to the given coordinate
    '''
    neighbours_lin_diff = (-1,-1,-1,0,1,1,1,0)
    neighbours_col_diff = (-1,0,1,1,1,0,-1,-1)

    valid_neighbours = ()

    for i in range(8): #We know that a coordinate has 8 neighbours, if all of its neighbours are valid coordinates
        neighbour_lin = this_lin+neighbours_lin_diff[i]
        neighbour_col = sumCol(neighbours_col_diff[i])

        if((1 <= neighbour_lin <= 99) and ('A' <= neighbour_col <= 'Z')):
            valid_neighbours += (cria_coordenada(neighbour_col,neighbour_lin),) 

    return valid_neighbours   

def obtem_coordenada_aleatoria(coordinate, generator):
    '''
    Returns a random coordinate with a column value between 'A' and the given coordinate's column value
    and a line value between 1 and the given coordinate's line value.

    coordinate -> coordenada
    generator -> gerador
    return -> coordenada
    '''
    col_random = gera_carater_aleatorio(generator,obtem_coluna(coordinate))
    lin_random = gera_numero_aleatorio(generator,obtem_linha(coordinate))
    return cria_coordenada(col_random,lin_random)
    
# --------------------------------------------------------

# TAD Parcela
# Chosen representation: type: list -> [str,bool] = [state,isThereMine]

def cria_parcela():
    '''
    Returns a parcel that is both hidden and without a mine
    
    return -> parcela
    '''
    return ["tapada",False]


def cria_copia_parcela(parcel):
    '''
    Returns a copy of the given parcel 

    parcel -> parcela
    return -> parcela
    '''
    return parcel.copy()

def limpa_parcela(parcel):
    '''
    Modifies the state of the given parcel to "limpa" and then returns it

    parcel -> parcela
    return -> parcela
    '''
    parcel[0] = "limpa"
    return parcel

def marca_parcela(parcel):
    '''
    Modifies the state of the given parcel to "marcada" and then returns it

    parcel -> parcela
    return -> parcela
    '''
    parcel[0] = "marcada"
    return parcel

def desmarca_parcela(parcel):
    '''
    Modifies the state of the given parcel to "tapada" and then returns it

    parcel -> parcela
    return -> parcela
    '''
    parcel[0] = "tapada"
    return parcel

def esconde_mina(parcel):
    '''
    Hides a mine in the given parcel (changes its isThereMine variable to True) and returns it

    parcel -> parcela
    return -> parcela
    '''
    parcel[1] = True
    return parcel

def eh_parcela(arg):
    '''
    Returns True if the given argument correctly represents a parcel,
    that is, if it follows the following representation: (state,isThereMine) 
    where state is a string and isThereMine a bool

    arg -> universal
    return -> bool
    '''
    return (type(arg) == list and len(arg) == 2 and type(arg[0]) == str and type(arg[1]) == bool \
        and (arg[0] in ("tapada","limpa","marcada")))

def eh_parcela_tapada(parcel):
    '''
    Returns True if the state of the given parcel is "tapada"
    
    parcel -> parcela
    return -> bool
    '''
    return (parcel[0] == "tapada")


def eh_parcela_marcada(parcel):
    '''
    Returns True if the state of the given parcel is "marcada"
    
    parcel -> parcela
    return -> bool
    '''
    return (parcel[0] == "marcada")

def eh_parcela_limpa(parcel):
    '''
    Returns True if the state of the given parcel is "limpa"
    
    parcel -> parcela
    return -> bool
    '''
    return (parcel[0] == "limpa")

def eh_parcela_minada(parcel):
    '''
    Returns True if the given parcel is hiding a mine
    
    parcel -> parcela
    return -> bool
    '''
    return parcel[1]

def parcelas_iguais(p1,p2): 
    '''
    Returns True if both parcels are equal

    p1 -> parcela
    p2 -> parcela
    return -> bool
    '''
    return (eh_parcela(p1) and eh_parcela(p2) and p1 == p2)

def parcela_para_str(parcel):
    '''
    Returns a string that represents the parcel depending on its state (its first element) 
    and wether or not they hide a mine (its second element):
    - '#' for parcels with state "tapada"
    - '@' for parcels with state "marcada"
    - '?' for parcels with state "limpa" and not hiding a mine
    - 'X' for parcels with state "limpa" and hiding a mine
    
    parcel -> parcela
    return -> str
    '''
    state = parcel[0]
    isThereMine = parcel[1]

    if isThereMine and state == "limpa":
        return 'X'
    elif state == "limpa":
        return '?'
    elif state == "marcada":
        return '@'
    elif state == "tapada":
        return "#"

# Funções de alto nível para Parcela

def alterna_bandeira(parcel):
    '''
    Modifies the given parcel state to "marcada" if it previously was "tapada" and vice-versa ("tapada" if "marcada")
    Otherwise doesn't modify the given parcel. Returns True if the given parcel was destructively modified.

    parcel -> parcela
    return -> bool
    '''

    if(eh_parcela_marcada(parcel)):
        desmarca_parcela(parcel)
    elif(eh_parcela_tapada(parcel)):
        marca_parcela(parcel)
    else:
        return False
    
    return True

#---------------------------------------------------

# TAD Campo
# Chosen representation: list[list[parcela]] -> list made out of lists containing parcela TAD
# Each sublist represents a line and each index in a sublist represents its column 

def cria_campo(last_col,last_lin):
    '''
    Returns a field where the last column corresponds to last_col and the last line correspond to last_lin

    last_col -> str
    last_lin -> int
    return -> campo 
    '''
    if(type(last_col) != str or len(last_col) != 1 or type(last_lin) != int or not('A' <= last_col <= 'Z') or not(1 <= last_lin <= 99)):
        raise ValueError("cria_campo: argumentos invalidos")
    
    return [[cria_parcela() for x in range(colParaIndex(last_col)+1)] for y in range(last_lin)]


def cria_copia_campo(field):
    '''
    Returns a copy of the given field

    field -> campo
    return -> campo
    '''
    
    field_copy = cria_campo(obtem_ultima_coluna(field),obtem_ultima_linha(field))
    for line in range(obtem_ultima_linha(field)):
        for column in range(colParaIndex(obtem_ultima_coluna(field))):
            coordinate = cria_coordenada(IndexParaCol(column),line+1)
            p_field_copy = obtem_parcela(field_copy,coordinate)
            p_field = obtem_parcela(field,coordinate)
            if not parcelas_iguais(p_field_copy,p_field):
                p_field_copy = p_field
    return field_copy

def obtem_ultima_coluna(field):
    '''
    Returns the letter corresponding to the last column of the given field

    field -> campo
    return -> str
    '''
    return chr(ord('A') + len(field[0])-1)

def obtem_ultima_linha(field):
    '''
    Returns the integer corresponding to the last line of the given field

    field -> campo
    return -> int
    '''
    return len(field)

def obtem_parcela(field, coordinate):
    '''
    Returns the parcel corresponding to the given coordinate location in the field

    field -> campo
    coordinate -> coordenada
    return -> parcela
    '''

    #Subtracting 1 from obtem_linha is required since the first index of a list is 0 and the first line is 1
    #In the case of the columns, this is not needed since ord('A') - ord('A') = 0 which corresponds to the first index
    return field[obtem_linha(coordinate)-1][ord(obtem_coluna(coordinate))-ord('A')]

def colParaIndex(col):
    return ord(col)-ord('A')

def IndexParaCol(ind):
        return chr(ind+ord('A'))

def obtem_coordenadas(field,state): 
    '''
    Returns the tuple containing the coordinates of the field depending on the state of each corresponding parcel

    field -> campo
    state -> str
    return -> tuple(coordenada)
    '''
    func = None
    if(state == "limpas"):
        func = eh_parcela_limpa
    elif(state == "tapadas"):
        func = eh_parcela_tapada
    elif(state == "marcadas"):
        func = eh_parcela_marcada
    elif(state == "minadas"):
        func = eh_parcela_minada
    
    max_lin = obtem_ultima_linha(field)
    max_col = obtem_ultima_coluna(field)
    res = ()
    for line in range(max_lin):
        res += tuple(cria_coordenada(IndexParaCol(column),line+1) for column in range(colParaIndex(max_col)+1) if func(field[line][column]))
    return res


def obtem_numero_minas_vizinhas(field, coordinate): 
    '''
    Returns the number of neighbour parcels hiding mines 

    field -> campo
    coordinate -> coordenada
    return -> int
    '''

    # we separate the neighbour coordinates into valid coordinates then we "convert" the coordinates into parcels and filter the parcels
    # based on those that are hiding mines
    return len(list((filter(eh_parcela_minada, map(lambda x: obtem_parcela(field,x) ,\
        filter(lambda x: eh_coordenada_do_campo(field,x),obtem_coordenadas_vizinhas(coordinate)))))))

def eh_campo(arg):
    '''
    Returns True if the given argument is a campo ADT

    arg -> universal
    return -> bool
    '''
    return (type(arg) == list and len(arg) != 0 and all((type(x) == list and len(x) != 0 and eh_parcela(y)) for x in arg for y in x) and \
        ('A' <= obtem_ultima_coluna(arg) <= 'Z') and (1 <= obtem_ultima_linha(arg) <= 99))

def eh_coordenada_do_campo(field, coordinate):
    '''
    Returns True if the given coordinate is valid inside the field (its within the boundaries)

    field -> campo
    coordinate -> coordenada
    return -> bool
    '''
    return eh_coordenada(coordinate) and (1 <= obtem_linha(coordinate) <= obtem_ultima_linha(field)) and ('A' <= obtem_coluna(coordinate) <= obtem_ultima_coluna(field))

def campos_iguais(field1,field2):
    '''
    Returns True if both given fields are a campo ADT and are equal

    f1,f2 -> campo
    return -> bool
    '''

    if(not(eh_campo(field1) and eh_campo(field2)) or \
        obtem_ultima_linha(field1) != obtem_ultima_linha(field2) or obtem_ultima_coluna(field1) != obtem_ultima_coluna(field2)):
        return False

    for line in range(obtem_ultima_linha(field1)):
        for column in range(colParaIndex(obtem_ultima_coluna(field1))):
            coordenada_atual = cria_coordenada(IndexParaCol(column),line+1)
            if not parcelas_iguais(obtem_parcela(field1,coordenada_atual),obtem_parcela(field2,coordenada_atual)):
                return False
    
    return True


def campo_para_str(field): 
    '''
    Returns a string that represents the field

    field -> campo
    return -> str
    '''

    def choose_str_representation(linha_pos,coluna_pos):
        '''
        "Chooses" the string representation of a given column and line index based on its state:
            - If the parcel is clean, we return the number of neighbour mines otherwise an empty space
            - If the parcel isn't clean, we just return the corresponding symbol
        '''
        str_parcela = parcela_para_str(field[linha_pos][coluna_pos])
        if(str_parcela == '?'):
            minas_vizinhas = obtem_numero_minas_vizinhas(field, cria_coordenada(IndexParaCol(coluna_pos),linha_pos+1))
            return str(minas_vizinhas) if minas_vizinhas != 0 else ' '
        else:
            return str_parcela

    res = ""
    letras = "".join(tuple(chr(x) for x in range(ord('A'),ord(obtem_ultima_coluna(field))+1)))
    traços = "-"*len(letras)

    res+= "   {letras}\n".format(letras = letras)
    res+= "  +{espaços}+\n".format(espaços = traços)
    for line in range(obtem_ultima_linha(field)):
        parcelas = "".join(tuple(choose_str_representation(line,column) for column in range(colParaIndex(obtem_ultima_coluna(field))+1)))
        res+="{linha}|{parcelas}|\n".format(linha = coordenada_para_str(cria_coordenada('A',line+1))[1:],parcelas = parcelas)
        # in the above line we can reuse coordenada_para_str which already adds a 0 to less than 10 integers by slicing the column part

    res +="  +{espaços}+".format(espaços = traços)

    return res

# Funções de alto nível para Campo

def coloca_minas(field, coordinate,generator, n_mines):
    '''
    Hides n_mines in parcels inside the given field, using a generator sequentially, while making sure each mine
    doesn't land on a position equal or neighbouring the given coordinate position and doesn't occupy the same place
    as a previously placed mine. 

    field -> campo
    coordinate -> coordenada
    generator -> gerador
    n_mines -> int
    return -> campo
    '''
    coordinate_max = cria_coordenada(obtem_ultima_coluna(field),obtem_ultima_linha(field))
    hidden_mines = 0
    while hidden_mines < n_mines:
        possible_coordinate = obtem_coordenada_aleatoria(coordinate_max,generator)
        if(coordenadas_iguais(possible_coordinate,coordinate) or \
            any(coordenadas_iguais(possible_coordinate,neighbour) for neighbour in obtem_coordenadas_vizinhas(coordinate)) or \
                eh_parcela_minada(obtem_parcela(field,possible_coordinate))):
                continue
        else:
            esconde_mina(obtem_parcela(field,possible_coordinate))
            hidden_mines += 1

    return field        

def limpa_campo(field, coordinate):
    '''
    Changes the state of the parcel in the given coordinate to "limpa" and, if there aren't any
    neighbour mines, changes the state of every neighbour parcel iteratively.
    If the parcel already has state "limpa" this function has no effect.

    field -> campo
    coordinate -> coordenada
    return -> campo
    '''
    corresponding_parcel = obtem_parcela(field,coordinate)

    if(not eh_parcela_limpa(corresponding_parcel)):
        limpa_parcela(corresponding_parcel)

        if(obtem_numero_minas_vizinhas(field,coordinate) == 0 and not eh_parcela_minada(corresponding_parcel)):
            for neighbour in obtem_coordenadas_vizinhas(coordinate):
                if(eh_coordenada_do_campo(field,neighbour) and eh_parcela_tapada(obtem_parcela(field,neighbour))):
                    limpa_campo(field,neighbour)

    return field
    
# ---------------------------------------------------------

# Minesweeper game logic

def jogo_ganho(field):
    '''
    Returns true if all parcels without mines have state "limpa"

    field -> campo
    return -> bool
    '''
    #If there aren't any parcels with state "marcada" nor "tapada" that aren't mined then the game ends in a victory
    return not(len(obtem_coordenadas(field,"marcadas")) + (len(obtem_coordenadas(field,"tapadas"))-len(obtem_coordenadas(field,"minadas"))))
 

def choose_coordinate(field):
    coordinate = input("Escolha uma coordenada:")
    while not(len(coordinate) == 3 and coordinate[1].isdigit() and coordinate[2].isdigit() \
         and eh_coordenada_do_campo(field,str_para_coordenada(coordinate))):
        coordinate = input("Escolha uma coordenada:")

    coordinate = str_para_coordenada(coordinate)
    return coordinate

def turno_jogador(field):
    '''
    Lets the player pick an action and a coordinate, returning False if the player chooses to clean a mine.

    field -> campo
    return -> bool
    '''

    action = input("Escolha uma ação, [L]impar ou [M]arcar:")
    while action not in ('L','M'):
        action = input("Escolha uma ação, [L]impar ou [M]arcar:")
    
    coordinate = choose_coordinate(field)

    chosen_parcel = obtem_parcela(field,coordinate)
    if(action == 'L'):
        if(eh_parcela_minada(chosen_parcel)):
            limpa_parcela(chosen_parcel)
            return False
        else:
            limpa_campo(field,coordinate)
    elif(action == 'M'):
        alterna_bandeira(chosen_parcel)

    return True

# Main function

def minas(last_col,last_lin,n_mines,generator_dimension,seed):
    '''
    Returns True if player is able to win minesweeper game

    last_col -> str
    last_lin -> int
    n_mines -> int
    generator_dimension -> int
    seed -> int
    '''

    def showField():
        flags = len(obtem_coordenadas(field,"marcadas"))
        print("   [Bandeiras {flags}/{minas}]".format(flags = flags,minas=n_mines))
        print(campo_para_str(field))
    
    def isGuaranteedValidField():
        '''
        Having space left for mines after choosing a coordinate to clean is only GUARANTEED if:
        - The field is 3x4 or 4x3

        The number of total parcels (number of cols * number of lines) minus the number of mines must never be inferior to 9 otherwise 
        it isn't guaranteed the first coordinate and its neighbours don't have mines.
        '''
        return (('C' <= last_col <= 'Z' and 4 <= last_lin <= 99) or ('D' <= last_col <= 'Z' and 3 <= last_lin <= 99)) and ((colParaIndex(last_col)+1)*last_lin - n_mines >= 9) 

    # Argument checking 
    if(type(last_col) != str or len(last_col) != 1 or type(last_lin) != int or type(n_mines) != int or n_mines <= 0 or not(isGuaranteedValidField())\
        or type(generator_dimension) != int or generator_dimension not in (32,64) or type(seed) != int or seed <= 0):
        raise ValueError("minas: argumentos invalidos")

    # Playing game
    field = cria_campo(last_col,last_lin)
    generator = cria_gerador(generator_dimension,seed)
    showField()

    initial_coordinate = choose_coordinate(field)
    coloca_minas(field,initial_coordinate,generator,n_mines)
    limpa_campo(field,initial_coordinate)
    showField()

    while not jogo_ganho(field):
        isMineClean = not turno_jogador(field)
        showField()

        if(isMineClean):
            print("BOOOOOOOM!!!")
            return False
    
    print("VITORIA!!!")
    return True
    
#print(minas('Z',20,30,32,1))


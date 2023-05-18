/*  iaed-23 - ist1106022 - project1 

Autor: João Fernandes
Descrição: Este programa consiste numa plataforma de gestão de carreiras 
de transporte público. Para esse efeito possui os seguintes comandos:

q - termina o programa.
c [<nome-da-carreira> [inverso]] - adiciona e lista carreiras.
p [<nome-de-paragem> [<latitude> <longitude>]] - adiciona e lista
paragens.
l <nome-da-carreira> <paragem-origem> <paragem-destino> <custo> <duracao> -
adiciona ligacoes.
i - lista intersecoes entre carreiras.
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "project1.h"

/* O vector 'carreiras' guarda todas as possíveis structs Carreiras criadas ao 
longo do programa */
Carreira carreiras[MAX_CARREIRAS];
int total_carreiras = 0; /* Contador do total de carreiras criadas */

/* O vetor 'paragens' guarda todas as possíveis structs Paragens criadas ao 
longo do programa */
Paragem paragens[MAX_PARAGENS];
int total_paragens = 0; /* Contador do total de paragens criadas */

int main(){
    char buffer[BUFSIZ];
    char *comando;

    /* Sinalizador que indica a intenção de terminar o programa */
    int termina = FALSE;

    while (fgets(buffer,BUFSIZ,stdin) != NULL)
    {
        comando = (char*)malloc(sizeof(char)*(strlen(buffer)+1));
        strcpy(comando,buffer);

        switch (comando[0])
        {
        case 'q':
            termina = TRUE;
            break;
        case 'c':
            comando_c(comando);
            break;
        case 'p':
            comando_p(comando);
            break;

        case 'l':
            comando_l(comando);
            break;
        
        case 'i':
            comando_i();
            break;
        
        default:
            printf("Nunca aparece pois o input dado esta certo.\n");
            continue;
        }

        free(comando);
        if(termina){
            break;
        }
    }
    
    free_all();
    return 0;
}

/* Liberta a memória alocada pelo programa no seu final */
void free_all(){
    int i;
    for(i=0; i < total_paragens; i++){
        free(paragens[i].nomes_carreiras);
    }
    for(i=0; i < total_carreiras;i++){
        free_carreira(i);
    }
}

/* Liberta a memória alocada por uma carreira particular */
void free_carreira(int i){
    Ligacao* temp = carreiras[i].head;
    while (temp != NULL)
    {
        Ligacao* next = temp->proxima;
        free(temp);
        temp = next;
    } 
}

/* Determina o comportamento do comando c consoante o numero de 
argumentos dados */
void comando_c(char comando[]){
    char nome[NOME_C_MAX],inverso[8],letra;
    int n_carreira, eh_inverso = FALSE;
    int n_arg = sscanf(comando,"%c%s%s",&letra,nome,inverso) - 1;

    switch (n_arg)
    {
    case 2:{
            /* Este bloco verifica se o 3o argumento 
            corresponde a palavra "inverso" ou uma das 
            suas abreviaturas */
            int n_letras_inverso = strlen(inverso);
            if(n_letras_inverso < 3 || 
            strncmp(inverso,"inverso",n_letras_inverso)){
                printf("incorrect sort option.\n");
                return;
            }
            eh_inverso = TRUE;
            n_carreira = carreira_existe(nome);
            print_carreira(n_carreira,eh_inverso);
            break;
        }
    case 1:
        n_carreira = carreira_existe(nome);
        if(n_carreira != NAO_EXISTE)
            print_carreira(n_carreira,eh_inverso);
        else
            cria_carreira(nome);
        break;
    default: /* Não foram dados argumentos extra */
        lista_carreiras();
        return;
    }
}

/* Determina o comportamento do comando p consoante o numero de 
argumentos dados */
void comando_p(char comando[]){
    char nome[NOME_P_MAX];
    int i=1;
    
    /*Este pointer percorrera o comando, pois sscanf aqui
    nao funcionaria corretamente, uma vez que existe a possibilidade
    de o nome de uma paragens ter carateres brancos*/
    char *c; 

    c = &comando[i];
    if(*c == '\n'){ /*O comando foi chamado sem argumentos*/
        lista_paragens();
    }
    else{
        c++; 
        i += nome_paragem(c,nome);
        if(comando[i] == '\n'){ /*O comando foi chamado com 1 argumento*/
            print_paragem(nome);
        }
        else{ /*O comando foi chamado com 3 argumentos*/
            double latitude, longitude;
            sscanf(&comando[i],"%lf%lf",&latitude,&longitude);
            cria_paragem(nome,latitude,longitude);
        }
    }
}

/* Determina o comportamento do comando l consoante o tipo de 
argumentos que lhe sao dados */
void comando_l(char comando[]){
    int n_carreira, n_origem, n_destino, pos_extensao=EXTENSAO_INVALIDA; 
    char *c; /* Pointer que irá percorrer o comando */
    char nome_carreira[NOME_C_MAX], nome_origem[NOME_P_MAX], 
    nome_destino[NOME_P_MAX];
    double custo, duracao;

    /*Verifica se a carreira e paragens dadas existem*/
    c = &comando[2];
    sscanf(c,"%s",nome_carreira);
    if((n_carreira = carreira_existe(nome_carreira)) == NAO_EXISTE) {
        printf("%s: no such line.\n",nome_carreira);
        return;
    }
    c += strlen(nome_carreira)+1;
    c += nome_paragem(c,nome_origem);
    if((n_origem = paragem_existe(nome_origem)) == NAO_EXISTE){
        printf("%s: no such stop.\n",nome_origem);
        return;
    }

    c += nome_paragem(c, nome_destino);
    if((n_destino = paragem_existe(nome_destino)) == NAO_EXISTE){
        printf("%s: no such stop.\n",nome_destino);
        return;
    }

    /* Verifica a validade da extensao dada, caso a carreira 
    ja possua paragens */
    if(carreiras[n_carreira].num_stops >= 2){
        if(!(pos_extensao = eh_extensao(n_carreira,n_origem,n_destino))){
            printf("link cannot be associated with bus line.\n");
            return;
        }
    }

    /* Verifica se o custo e duracao dados sao validos */
    sscanf(c,"%lf%lf", &custo, &duracao);
    if(custo < 0 || duracao < 0){
        printf("negative cost or duration.\n");
        return;
    }
    
    /*Se passar todas verificacoes, pode ser adicionada a carreira*/
    adiciona_ligacao(n_carreira,n_origem,n_destino,custo,duracao,pos_extensao);
}

/* Funcao correspondente a funcionalidade do comando 'i' */
void comando_i(){
    int i,j;
    
    /* Vetor temporario onde o program ira guardar cada vetor de strings 
    para as paragens com mais do que uma carreira, para as 
    ordenar alfabeticamente */
    char** intersecoes = NULL;

    /* Para cada paragem (pela sua ordem de criacao), 
    verifica se nela param mais de uma carreira e caso aconteca,
    lista os seus nomes de forma alfabetica */
    for(i=0; i < total_paragens;i++){
        if(paragens[i].num_carreiras > 1){
            printf("%s %d: ",paragens[i].nome,paragens[i].num_carreiras);

            intersecoes = paragens[i].nomes_carreiras;
            sort_nomes(intersecoes,paragens[i].num_carreiras);
            for(j=0; j < paragens[i].num_carreiras; j++){
                if(j == 0){
                    printf("%s",paragens[i].nomes_carreiras[j]);
                    continue;
                }
                printf(" %s",paragens[i].nomes_carreiras[j]);
            }
            putchar('\n');
        }
    }
}

/* Função responsável de atribuir a var 'nome' o nome de uma paragem,
incluindo nomes com carateres brancos (delimitados por aspas) */
int nome_paragem(char* letra_comando,char nome[]){

    /*Indica o numero de char que sao percorridos ate obter nome*/
    int i=0;

    if(*letra_comando == '\"'){
        letra_comando++;
        while (*letra_comando != '\"')
        {
            nome[i] = *letra_comando;
            i++;
            letra_comando++;
        }
        nome[i] = '\0';
        i+=2; /*Para percorrer as duas aspas omitidas*/
    }
    else{
        while (*letra_comando != ' ' && *letra_comando != '\n')
        {
            nome[i] = *letra_comando;
            i++;
            letra_comando++;
        }
        nome[i] = '\0';
    }
    return i+1; /*Para retornar a posição a seguir à última letra*/
}

/*Função que imprime os conteúdos de cada paragem pela ordem de criação*/
void lista_paragens(){
    int i;
    for(i=0; i < total_paragens;i++){
        printf("%s: %16.12f %16.12f %d\n",paragens[i].nome,paragens[i].latitude,
            paragens[i].longitude,paragens[i].num_carreiras);
    }
}

/*Função que imprime os conteúdos de uma dada paragem*/
void print_paragem(char nome_paragem[]){
    int n_paragem = paragem_existe(nome_paragem);

    if(n_paragem != NAO_EXISTE)
        printf("%16.12f %16.12f\n",paragens[n_paragem].latitude, 
        paragens[n_paragem].longitude);
    else
        printf("%s: no such stop.\n",nome_paragem);
}

/*Função que cria uma nova paragem, adicionando-a ao vector 'paragens'*/
void cria_paragem(char nome_paragem[], double latitude, double longitude){
    if(paragem_existe(nome_paragem) == NAO_EXISTE){
        strcpy(paragens[total_paragens].nome,nome_paragem);
        paragens[total_paragens].latitude = latitude;
        paragens[total_paragens].longitude = longitude;

        /* Visto não ser muito comum mais de 10 carreiras passarem na
        mesma paragem optei por alocar inicialmente apenas
        10*sizeof(char*) bytes, sendo este espaço realocado para 
        o dobro se necessária na função adiciona_intersecao*/
        paragens[total_paragens].espaco_alocado_intersecao = 
            sizeof(char*) * N_INI_INTERSECOES;

        /*As 10 carreiras são inicializadas a null para depois não ser 
        acedido conteúdo indesejado*/
        paragens[total_paragens].nomes_carreiras = 
            (char**)calloc(N_INI_INTERSECOES,
            paragens[total_paragens].espaco_alocado_intersecao);

        /*O número de carreiras que passam numa paragem 
        quando é criada é 0 */
        paragens[total_paragens].num_carreiras = 0;

        total_paragens++;
    }
    else{
        printf("%s: stop already exists.\n",nome_paragem);
    }
}

/* Verifica e retorna a posição da paragem com nome 'nome_paragem',
se não existir retorna NÃO_EXISTE */
int paragem_existe(char nome_paragem[]){
    int i=0;
    while (i < total_paragens)
    {
        if(strcmp(paragens[i].nome,nome_paragem) == 0)
            return i;
        i++;
    }
    return NAO_EXISTE;
}

/*Função que imprime os conteúdos de cada carreira por ordem de criação */
void lista_carreiras(){
    int i;
    for(i=0; i < total_carreiras;i++){
        /*Se não tiver paragens, também não terá duração nem preço.*/
        if(carreiras[i].num_stops == 0)
            printf("%s %d %.2f %.2f\n",carreiras[i].nome,0,0.0,0.0);
        else
            printf("%s %s %s %d %.2f %.2f\n",carreiras[i].nome,
            carreiras[i].origem->nome,carreiras[i].destino->nome,
            carreiras[i].num_stops,carreiras[i].custo_total,
            carreiras[i].duracao_total);
    }
}

/* Função que imprime os conteúdos de uma dada carreira */
void print_carreira(int n_carreira, int eh_inverso){

    if(carreiras[n_carreira].head == NULL) /* Se não possuir ligações */
        return;
    else if(eh_inverso)
        print_carreira_inverso(n_carreira,carreiras[n_carreira].head);
    else{
        Ligacao* iterador = carreiras[n_carreira].head;
        if(iterador != NULL){
            printf("%s",iterador->atual->nome);
            iterador = iterador->proxima;
        }    
        while (iterador != NULL)
        {
            printf(", %s",iterador->atual->nome);
            iterador = iterador->proxima;
        }
    }
    putchar('\n');
}

/* Imprime os conteúdos de uma dada carreira pela ordem inversa */
void print_carreira_inverso(int n_carreira, Ligacao* head){
    if(head == NULL){
        return;
    }

    print_carreira_inverso(n_carreira,head->proxima);
    if(head->proxima == NULL)
        printf("%s",head->atual->nome);
    else
        printf(", %s",head->atual->nome);
}

/* Função que cria uma carreira e lhe adiciona ao vetor 'carreiras' */
void cria_carreira(char nome_carreira[]){
    strcpy(carreiras[total_carreiras].nome,nome_carreira);

    carreiras[total_carreiras].origem = NULL;
    carreiras[total_carreiras].destino = NULL;
    carreiras[total_carreiras].head = NULL;
    carreiras[total_carreiras].custo_total = 0.0;
    carreiras[total_carreiras].duracao_total = 0.0;
    carreiras[total_carreiras].num_stops = 0;

    total_carreiras++;
}

/* Verificar e retorna a posição da carreira com nome 'nome_carreira',
se não existir retorna NÃO_EXISTE */
int carreira_existe(char nome_carreira[]){
    int i=0;
    while (i < total_carreiras)
    {
        if(strcmp(carreiras[i].nome,nome_carreira) == 0)
            return i;
        i++;
    }
    return NAO_EXISTE;
}

/* Verifica se dadas paragens formam ligação válida em dada carreira,
retornado o tipo extensão que fazem a esta */
int eh_extensao(int n_carreira,int n_origem,int n_destino){
    if(carreiras[n_carreira].destino == &paragens[n_origem])
        return DEPOIS_DESTINO;
    else if(carreiras[n_carreira].origem == &paragens[n_destino])
        return ANTES_ORIGEM;
    else
        return EXTENSAO_INVALIDA;
}

/* Adiciona uma dada ligação de paragem com num 'n_origem' até paragem
com num 'n_destino', tendo em conta o tipo de extensão ('pos_extensão'),
à carreira de num 'n_carreira' e com dado custo e duração */
void adiciona_ligacao(int n_carreira,int n_origem, int n_destino, double custo, 
    double duracao, int pos_extensao){

    /*Caso a carreira ainda estiver vazia*/
    if(carreiras[n_carreira].head == NULL){ 

        carreiras[n_carreira].head = (Ligacao*) malloc(sizeof(Ligacao));
        carreiras[n_carreira].head->atual = &(paragens[n_origem]);
        carreiras[n_carreira].head->proxima = NULL;

        carreiras[n_carreira].origem = carreiras[n_carreira].head->atual;
        carreiras[n_carreira].destino = 
            ad_ligacao_final(n_destino,carreiras[n_carreira].head)->atual;

        carreiras[n_carreira].num_stops += 2; 
    }
    /* Caso a paragem de origem seja anterior à origem da carreira */
    else if(pos_extensao == ANTES_ORIGEM){
        carreiras[n_carreira].origem = 
            ad_ligacao_inicio(n_origem,&carreiras[n_carreira].head)->atual;
        carreiras[n_carreira].num_stops++;
    }
    /* Caso a paragem de destino seja depois do destino da carreira */
    else if(pos_extensao == DEPOIS_DESTINO){
        carreiras[n_carreira].destino = 
            ad_ligacao_final(n_destino,carreiras[n_carreira].head)->atual;
        carreiras[n_carreira].num_stops++;
    }    
    carreiras[n_carreira].custo_total += custo;
    carreiras[n_carreira].duracao_total += duracao;

    /* A carreira é adicionada à lista de interseções das 
    paragens de destino e origem, caso não o tenham sido ainda */
    adiciona_intersecao(n_origem,carreiras[n_carreira].nome);
    adiciona_intersecao(n_destino,carreiras[n_carreira].nome);
}

Ligacao* ad_ligacao_inicio(int n_paragem, Ligacao** head_prev){
    Ligacao *head_new = (Ligacao*) malloc(sizeof(Ligacao));
    head_new->atual = &(paragens[n_paragem]);
    head_new->proxima = *head_prev;
    *head_prev = head_new;

    return *head_prev;
}

Ligacao* ad_ligacao_final(int n_paragem, Ligacao* head){
    Ligacao* seguinte = head;
    while (seguinte->proxima != NULL) 
    {
        seguinte = seguinte->proxima;
    }
    seguinte->proxima = (Ligacao*) malloc(sizeof(Ligacao));
    seguinte->proxima->atual = &(paragens[n_paragem]);
    seguinte->proxima->proxima = NULL;
    
    return seguinte->proxima;
}

/* Adiciona dado nome de carreira com 'nome_intersecao'
à lista de interseções da paragem de num 'n_paragem', 
se ainda não existir nesta lista */
void adiciona_intersecao(int n_paragem, char nome_intersecao[]){

    if(intersecao_existe(n_paragem,nome_intersecao) == NAO_EXISTE){
        
        /* Aloca uma quantidade de espaço correspondente ao dobro do
        anteriormente alocada caso seja necessário. */
        if(paragens[n_paragem].espaco_alocado_intersecao < 
            paragens[n_paragem].num_carreiras*sizeof(char*)){

            paragens[n_paragem].nomes_carreiras = 
                (char**) realloc(paragens[n_paragem].nomes_carreiras,
                paragens[n_paragem].espaco_alocado_intersecao*2);
        }

        /* Adiciona o nome da carreira ao final da lista de carreiras 
        que se intersetam */
        paragens[n_paragem].nomes_carreiras[paragens[n_paragem].num_carreiras]= 
            nome_intersecao;

        paragens[n_paragem].num_carreiras++;
    }
}

/* Verifica se dada carreira já consta na lista de carreiras que se intersetam
na paragem de num 'n_paragem', retornando a sua posição, caso contrário
retorna NAO_EXISTE */
int intersecao_existe(int n_paragem, char nome_intersecao[]){
    int i=0;
    while (i < paragens[n_paragem].num_carreiras)
    {
        if(strcmp(paragens[n_paragem].nomes_carreiras[i],nome_intersecao) == 0)
            return i;
        i++;
    }
    return NAO_EXISTE;
}

/* Ordena o vetor de strings 'nomes' por ordem alfabética */
void sort_nomes(char** nomes, int length){
    int i,j;
    for(i=0; i < length-1;i++){
        for(j=i+1;j<length;j++){
            if(strcmp(nomes[i],nomes[j])>0){
                char* temp = nomes[i];
                nomes[i] = nomes[j];
                nomes[j] = temp;
            }
        }
    }
}
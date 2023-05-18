/*
Autor: João Fernandes
Descrição: Este ficheiro contém todas as funções relevantes às 
funcionalidades do programa e a maioria das suas funções auxiliares,
excluindo-se as funções que gerem a memória utilizada.
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "project2.h"

/* Determina o comportamento do comando c consoante o numero de 
argumentos dados */
void comando_c(char* comando, Listas** refs){
    char* nome, inverso[8],*letra = &comando[1];
    Carreira* arg_carreira;
    if(*letra == '\n')
        lista_carreiras((*refs)->head_carreiras);
    else{
        int eh_inverso = FALSE;
        letra++;
        nome = obter_nome(&letra,refs);
        if(nome == NULL)
            exit(0);
        arg_carreira = carreira_existe(nome,(*refs)->head_carreiras);
        if(*letra == '\n'){
            if(arg_carreira != NULL)
                print_carreira(arg_carreira,eh_inverso);
            else
                cria_carreira(nome,refs);
        }
        else{
            sscanf(letra,"%s",inverso);
            if(eh_inverso_certo(inverso)){
                eh_inverso = TRUE;
                print_carreira(arg_carreira,eh_inverso);
            }
            else
                printf("incorrect sort option.\n"); 
        }
        free(nome);
    }
}

/* Determina o comportamento do comando p consoante o numero de 
argumentos dados */
void comando_p(char *comando, Listas** refs){
    char* nome;
    char *c = &comando[1];

    if(*c == '\n') /*O comando foi chamado sem argumentos*/
        lista_paragens((*refs)->head_paragens);
    else{
        c++; 
        nome = obter_nome(&c,refs);
        if(nome == NULL)
            exit(0);
        if(*c == '\n') /*O comando foi chamado com 1 argumento*/
            print_paragem(nome,(*refs)->head_paragens);
        else{ /*O comando foi chamado com 3 argumentos*/
            double latitude, longitude;
            sscanf(c,"%lf%lf",&latitude,&longitude);
            cria_paragem(nome,latitude,longitude,refs);
        }
        free(nome);
    }
}

/* Determina o comportamento do comando l consoante o tipo de 
argumentos que lhe sao dados */
void comando_l(char* comando, Listas** refs){
    Carreira* arg_carreira;
    Paragem *arg_origem, *arg_destino;
    int pos_extensao=EXTENSAO_INVALIDA;
    char *c = &comando[2]; /* Pointer que irá percorrer o comando */
    double custo, duracao;

    if((arg_carreira = verifica_carreira(&c,refs)) == NULL)
        return;
    if((arg_origem = verifica_paragem(&c,refs)) == NULL)
        return;
    if((arg_destino = verifica_paragem(&c,refs)) == NULL)
        return;
    /* Verifica a validade da extensao dada, caso a carreira 
    ja possua paragens */
    if(arg_carreira->num_stops >= 2){
        if(!(pos_extensao = eh_extensao(arg_carreira,arg_origem,arg_destino))){
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
    adiciona_ligacao(arg_carreira,arg_origem,arg_destino,
        custo,duracao,pos_extensao,refs);
}

/*Verifica a existencia de uma carreira na lista de carreiras existentes*/
Carreira* verifica_carreira(char** letra_comando, Listas** refs){
    Carreira* arg_carreira;
    char* nome_carreira = obter_nome(letra_comando,refs);
    if(nome_carreira == NULL)
        exit(0);

    if((arg_carreira = 
        carreira_existe(nome_carreira,(*refs)->head_carreiras)) == NULL)
        printf("%s: no such line.\n",nome_carreira);
    free(nome_carreira);
    return arg_carreira;
}

/*Verifica a existencia de um paragem na lista de paragens existentes*/
Paragem* verifica_paragem(char** letra_comando, Listas** refs){
    Paragem* arg_paragem;
    char* nome_paragem = obter_nome(letra_comando,refs);
    if(nome_paragem == NULL)
        exit(0);
    if((arg_paragem = 
        paragem_existe(nome_paragem,(*refs)->head_paragens)) == NULL){
        printf("%s: no such stop.\n",nome_paragem);
    }
    free(nome_paragem);
    return arg_paragem;
}

/* Funcao correspondente a funcionalidade do comando 'i':
    Para cada paragem (pela sua ordem de criacao), verifica se 
    nela param mais de uma carreira e caso aconteca, lista os 
    seus nomes de forma alfabetica  */                    
void comando_i(Paragem* head){
    Paragem* iter_par = head;
    while (iter_par != NULL)
    {
        if(iter_par->num_intersecoes > 1){
            printf("%s %d: ",iter_par->nome,iter_par->num_intersecoes);
            sort_nomes_intersecoes(&(iter_par->intersec_head));
            lista_intersecoes(iter_par->intersec_head);
        }
        iter_par=iter_par->next;
    }
}

/*Funcionalidade do comando r*/
void comando_r(char* comando, Listas** refs){
    char *nome,*letra_comando = &comando[2];
    Carreira* to_be_deleted;

    nome = obter_nome(&letra_comando,refs);
    if(nome == NULL)
        exit(0);

    /*Verifica se existe alguma carreira com esse nome*/
    if((to_be_deleted = 
        carreira_existe(nome,(*refs)->head_carreiras)) == NULL){
        printf("%s: no such line.\n",nome);
        free(nome);
        return; 
    }

    /*Apaga a carreira*/
    delete_carreira(&to_be_deleted,refs);
    free(nome);
}

/*Funcionalidade do comando e*/
void comando_e(char* comando, Listas** refs){
    Paragem* to_be_deleted;
    char *letra_comando = &comando[2],*nome;
    nome = obter_nome(&letra_comando,refs);
    if(nome == NULL)
        exit(0);

    if((to_be_deleted = 
        paragem_existe(nome,(*refs)->head_paragens)) == NULL){
        printf("%s: no such stop.\n",nome);
        free(nome);
        return;
    }

    delete_paragem(&to_be_deleted,refs);
    free(nome);
}

/*  Retorna o primeiro nome que extrair do comando dado,
funcionando tanto para carreiras como paragens. */
char* obter_nome(char** letra_comando,Listas** refs){
    int i=0;
    char *nome, *buf_nome = 
        allocate_memory(sizeof(char)*(MAX_TAMANHO_LINHA+1),refs); 
    if(buf_nome == NULL)
        return NULL;
    if(**letra_comando == '\"'){
        letra_comando[0]++;
        while (**letra_comando != '\"'){
            buf_nome[i++] = **letra_comando;
            letra_comando[0]++;
        }
        buf_nome[i] = '\0';
        letra_comando[0]++;
    }
    else{
        while (**letra_comando != ' ' && **letra_comando != '\n')
        {
            buf_nome[i++] = **letra_comando;
            letra_comando[0]++;
        }
        buf_nome[i] = '\0';
    }
    if(**letra_comando != '\n')
        letra_comando[0]++;

    nome = allocate_memory(sizeof(char)*(strlen(buf_nome)+1),refs);
    if(nome == NULL){
        free(buf_nome);
        return NULL;
    }
    strcpy(nome,buf_nome);
    free(buf_nome);
    return nome;
}

/*Função que imprime os conteúdos de cada paragem pela ordem de criação*/
void lista_paragens(Paragem* head){
    Paragem* iter = head;
    while (iter != NULL){
        printf("%s: %16.12f %16.12f %d\n",iter->nome,iter->latitude,
            iter->longitude,iter->num_intersecoes);
        iter = iter->next;
    }
}

/*Função que imprime os conteúdos de uma dada paragem*/
void print_paragem(char* nome_paragem, Paragem* head){
    Paragem* arg_paragem = paragem_existe(nome_paragem,head);

    if(arg_paragem != NULL)
        printf("%16.12f %16.12f\n",arg_paragem->latitude, 
            arg_paragem->longitude);
    else    
        printf("%s: no such stop.\n",nome_paragem);
}

/*Função que cria uma nova paragem, adicionando-a ao vector 'paragens'*/
void cria_paragem(char* nome_paragem, double latitude, 
    double longitude, Listas** refs){
    if(paragem_existe(nome_paragem,(*refs)->head_paragens) == NULL){
        Paragem* new_last = init_paragem(nome_paragem,latitude,longitude,refs);
        if(new_last == NULL)
            exit(0);
        adiciona_paragem(new_last,refs);
    }
    else
        printf("%s: stop already exists.\n",nome_paragem);
}

/*Inicializa uma paragem com os dados fornecidos*/
Paragem* init_paragem(char* nome_paragem, double latitude, 
    double longitude, Listas** refs){
    Paragem* par = allocate_memory(sizeof(Paragem),refs);
    if(par == NULL)
        return NULL;
    par->nome = allocate_memory(sizeof(char)*(strlen(nome_paragem)+1),refs);
    if(par->nome == NULL){
        free(par);
        return NULL;
    }
    strcpy(par->nome,nome_paragem);
    par->latitude = latitude;
    par->longitude = longitude;
    par->num_intersecoes = 0;
    par->intersec_head = NULL;
    return par;
}

/* Adiciona paragem ao final da lista de paragens já existentes */
void adiciona_paragem(Paragem* par, Listas** refs){
    if((*refs)->head_paragens == NULL){
        (*refs)->head_paragens = par;
        (*refs)->head_paragens->previous = NULL;
        (*refs)->head_paragens->next = (*refs)->last_paragens;
    }
    else if((*refs)->last_paragens == NULL){
        (*refs)->last_paragens = par;
        (*refs)->last_paragens->next = NULL;
        (*refs)->last_paragens->previous = (*refs)->head_paragens;
        (*refs)->head_paragens->next = (*refs)->last_paragens;
    }
    else{
        par->next = NULL;
        par->previous = (*refs)->last_paragens;
        (*refs)->last_paragens->next = par;
        (*refs)->last_paragens = par;
    }
}

/*  Verifica se uma paragem existir e, caso exista, 
retorna um ponteiro para esta   */
Paragem* paragem_existe(char* nome_paragem, Paragem* head){
    Paragem* iter = head;
    while (iter != NULL){
        if(!strcmp(nome_paragem,iter->nome))
            return iter;
        iter = iter->next;
    }
    return NULL;
}

/*Verfica se "inverso" foi bem escrito*/
int eh_inverso_certo(char* inverso){
    int n_letras_inverso = strlen(inverso);
    if(n_letras_inverso < 3 || 
            strncmp(inverso,"inverso",n_letras_inverso))
                return FALSE;
    else
        return TRUE;
}

/*Função que imprime os conteúdos de cada carreira por ordem de criação */
void lista_carreiras(Carreira* head){
    Carreira* iter = head;
    while (iter != NULL){
        if(iter->num_stops == 0)
            printf("%s %d %.2f %.2f\n",iter->nome,0,0.0,0.0);
        else{
            printf("%s %s %s %d %.2f %.2f\n",iter->nome,
            iter->head->atual->nome,iter->last->atual->nome,
            iter->num_stops,iter->custo_total,
            iter->duracao_total);         
        }
        iter = iter->next;
    }
}

/* Função que imprime os conteúdos de uma dada carreira */
void print_carreira(Carreira* arg_carreira, int eh_inverso){
    if(arg_carreira->head == NULL) /* Se não possuir ligações */
        return;
    else if(eh_inverso)
        print_carreira_inverso(arg_carreira);
    else{
        Ligacao* iterador = arg_carreira->head;
        if(iterador != NULL){
            printf("%s",iterador->atual->nome);
            iterador = iterador->proxima;
        }    
        while (iterador != NULL){
            printf(", %s",iterador->atual->nome);
            iterador = iterador->proxima;
        }
    }
    putchar('\n');
}

/* Imprime os conteúdos de uma dada carreira pela ordem inversa */
void print_carreira_inverso(Carreira* arg_carreira){
    Ligacao* iter = arg_carreira->last;
    printf("%s",arg_carreira->last->atual->nome);
    iter = iter->anterior;
    
    while (iter != NULL){
        printf(", %s",iter->atual->nome);
        iter = iter->anterior;
    }
}


/* Função que cria uma carreira e lhe adiciona ao vetor 'carreiras' */
void cria_carreira(char* nome_carreira,Listas** refs){

    Carreira* new_last = init_carreira(nome_carreira,refs);
    if(new_last == NULL)
        exit(0);
    adiciona_carreira(new_last,refs);
}

/*Inicializa uma carreira com os dados fornecidos*/
Carreira* init_carreira(char* nome_carreira, Listas** refs){
    Carreira* car = allocate_memory(sizeof(Carreira),refs);
    if(car == NULL)
        return NULL;
    car->nome = allocate_memory(sizeof(char)*(strlen(nome_carreira)+1),refs);
    if(car->nome == NULL){
        free(car);
        return NULL;
    }
    strcpy(car->nome,nome_carreira);

    car->head = NULL;
    car->last = NULL;
    car->custo_total = 0.0;
    car->duracao_total = 0.0;
    car->num_stops = 0;

    return car;
}

/*Adiciona a carreira ao final da lista de carreiras já existentes*/
void adiciona_carreira(Carreira* car, Listas** refs){
    if((*refs)->head_carreiras == NULL){ /*Não existem ainda carreiras*/
        (*refs)->head_carreiras = car;
        (*refs)->head_carreiras->previous = NULL;
        (*refs)->head_carreiras->next = (*refs)->last_carreiras;
    }
    else if((*refs)->last_carreiras == NULL){ /*Existe uma só carreira*/
        (*refs)->last_carreiras = car;
        (*refs)->last_carreiras->previous = (*refs)->head_carreiras;
        (*refs)->last_carreiras->next = NULL;
        (*refs)->head_carreiras->next = (*refs)->last_carreiras;
    }
    else{ /* Existem 2 ou mais carreiras */
        car->previous = (*refs)->last_carreiras;
        car->next = NULL;
        (*refs)->last_carreiras->next = car;
        (*refs)->last_carreiras = car;
    }
}

/*  Verifica se uma carreira existir e, caso exista, 
retorna um ponteiro para esta   */
Carreira* carreira_existe(char* nome_carreira,Carreira* head){
    Carreira* iter = head;
    while (iter != NULL){
        if(!strcmp(nome_carreira,iter->nome))
            return iter;
        iter = iter->next;
    }
    return NULL;
}

/* Verifica se dadas paragens formam ligação válida em dada carreira,
retornado o tipo extensão que fazem a esta */
int eh_extensao(Carreira* arg_carreira,Paragem* arg_origem,
    Paragem* arg_destino){
    if(arg_carreira->last->atual == arg_origem)
        return DEPOIS_DESTINO;
    else if(arg_carreira->head->atual == arg_destino)
        return ANTES_ORIGEM;
    else
        return EXTENSAO_INVALIDA;
}

/* Adiciona a ligacao da paragem 'arg_origem' até à paragem 
'arg_destino', tendo em conta o tipo de extensão que 
formam, à lista de ligações da carreira 'arg_carreira' */
void adiciona_ligacao(Carreira* arg_carreira,Paragem* arg_origem, 
    Paragem* arg_destino, double custo, double duracao, 
    int pos_extensao, Listas** refs){

    /*Caso a carreira ainda estiver vazia*/
    if(arg_carreira->head == NULL)
        init_ligacao(arg_carreira,arg_origem,arg_destino,custo,duracao,refs);
    /* Caso a paragem de origem seja anterior à origem da carreira */
    else if(pos_extensao == ANTES_ORIGEM){
        ad_ligacao_inicio(arg_origem,&(arg_carreira->head),custo,duracao,refs);
        arg_carreira->num_stops++; 
        adiciona_intersecao(arg_origem,arg_carreira,refs);
    }

    /* Caso a paragem de destino seja depois do destino da carreira */
    else if(pos_extensao == DEPOIS_DESTINO){
        ad_ligacao_final(arg_destino,&(arg_carreira->last),custo,duracao,refs);
        arg_carreira->num_stops++; 
        adiciona_intersecao(arg_destino,arg_carreira,refs);
    }
    arg_carreira->custo_total += custo;
    arg_carreira->duracao_total += duracao;
}

/*Inicializa uma Ligacão com os dados fornecidos*/
void init_ligacao(Carreira* arg_carreira,Paragem* arg_origem, 
    Paragem* arg_destino, double custo, double duracao, Listas** refs){
        arg_carreira->head = allocate_memory(sizeof(Ligacao),refs);
        if(arg_carreira->head == NULL)
            exit(0);
        arg_carreira->head->atual = arg_origem;
        arg_carreira->head->anterior = NULL;
        
        arg_carreira->last = allocate_memory(sizeof(Ligacao),refs);
        if(arg_carreira->last == NULL){
            free(arg_carreira->head);
            exit(0);
        }
        arg_carreira->last->atual = arg_destino;
        arg_carreira->last->proxima = NULL;

        arg_carreira->head->proxima = arg_carreira->last;
        arg_carreira->last->anterior = arg_carreira->head;

        /*Numa ligacao entre duas paragens, é a primeira 
        que fica com o custo e duracao associado*/
        arg_carreira->head->custo = custo;
        arg_carreira->head->duracao = duracao;
        arg_carreira->num_stops += 2;

        adiciona_intersecao(arg_origem,arg_carreira,refs);
        adiciona_intersecao(arg_destino,arg_carreira,refs);
}

/*Adiciona uma paragem ao inicio de uma carreira*/
void ad_ligacao_inicio(Paragem* origem, Ligacao** head_prev, 
    double custo, double duracao,Listas** refs){
    Ligacao *head_new = allocate_memory(sizeof(Ligacao),refs);
    if(head_new == NULL)
        exit(0);
    head_new->atual = origem;
    head_new->proxima = *head_prev;
    head_new->anterior = NULL;
    head_new->custo = custo;
    head_new->duracao = duracao;
    (*head_prev)->anterior = head_new; 
    *head_prev = head_new;
}

/*Adiciona uma paragem ao fim de uma carreira*/
void ad_ligacao_final(Paragem* destino, Ligacao** last_prev, 
    double custo, double duracao, Listas** refs){
    Ligacao *last_new = allocate_memory(sizeof(Ligacao),refs);
    if(last_new == NULL)
        exit(0);
    last_new->atual = destino;
    last_new->anterior = *last_prev;
    last_new->proxima = NULL;
    (*last_prev)->proxima = last_new;
    (*last_prev)->custo = custo;
    (*last_prev)->duracao = duracao;
    *last_prev = last_new;
}

/* Adiciona um ponteiro para um carreira ao inicio da lista de 
ponteiros para carreiras que se intersetam na paragem 'arg_paragem' */
void adiciona_intersecao(Paragem* arg_paragem, 
    Carreira* arg_carreira,Listas** refs){
    if(arg_paragem->intersec_head == NULL){
        arg_paragem->intersec_head = 
            allocate_memory(sizeof(Intersecao),refs);
        if(arg_paragem->intersec_head == NULL)
            exit(0);
        arg_paragem->intersec_head->atual = arg_carreira;
        arg_paragem->intersec_head->proxima = NULL;
        arg_paragem->intersec_head->anterior = NULL;
        arg_paragem->num_intersecoes++;
    }
    else if(intersecao_existe(arg_paragem,arg_carreira) == NULL){
        /* Adiciona o nome da carreira ao inicio da lista */
        Intersecao* new_head_intersec = 
            allocate_memory(sizeof(Intersecao),refs);
        if(new_head_intersec == NULL)
            exit(0);
        new_head_intersec->atual = arg_carreira;
        new_head_intersec->anterior = NULL;
        new_head_intersec->proxima = arg_paragem->intersec_head;
        arg_paragem->intersec_head->anterior = new_head_intersec;
        arg_paragem->intersec_head = new_head_intersec;
        arg_paragem->num_intersecoes++;
    }
}

/* Verifica se dado ponteiro para carreira já consta na lista destas 
que se intersetam na paragem 'arg_paragem', se não for o caso retorna NULL*/
Intersecao* intersecao_existe(Paragem* arg_paragem, Carreira* arg_carreira){
   Intersecao* iter = arg_paragem->intersec_head;
   while (iter != NULL){
        if(iter->atual == arg_carreira)
            return iter;
        iter = iter->proxima; 
   }
    return NULL;
}

/*  Ordenada alfabeticamente a lista de interseções de uma dada paragem*/
void sort_nomes_intersecoes(Intersecao** head){
    Intersecao* head_sorted = NULL;
    Intersecao* iter = *head;

    while (iter != NULL){
        Intersecao* next = iter->proxima;
        iter->anterior = iter->proxima = NULL;
        insert_sorted(&head_sorted,iter);
        iter = next;
    }
    *head = head_sorted;
}

/*Insere uma dada interseção numa lista de interseções de forma ordenada*/
void insert_sorted(Intersecao** head, Intersecao* to_insert){
    if(*head == NULL)
        *head = to_insert;
    else if(strcmp((*head)->atual->nome,to_insert->atual->nome) >= 0){
        to_insert->proxima = *head;
        (*head)->anterior = to_insert;
        *head = to_insert;
    }
    else{
        Intersecao* iter = *head;
        while (iter->proxima != NULL && 
            strcmp(iter->proxima->atual->nome,to_insert->atual->nome) < 0){   
            iter = iter->proxima;
        }
        to_insert->proxima = iter->proxima;
        
        if(iter->proxima != NULL)
            to_insert->proxima->anterior = to_insert;
        
        iter->proxima = to_insert;
        to_insert->anterior = iter;
    }
}

/* Imprime os nomes das intersecoes de uma dada paragem */
void lista_intersecoes(Intersecao* head){
    Intersecao* iter = head;
    printf("%s",iter->atual->nome);
    iter=iter->proxima;
    while (iter != NULL){
        printf(" %s",iter->atual->nome);
        iter = iter->proxima;
    }
    putchar('\n');
}

#ifndef PROJECT1_H
#define PROJECT1_H

#define FALSE 0
#define TRUE 1
#define NAO_EXISTE -1

#define NOME_P_MAX 50
#define NOME_C_MAX 20

#define MAX_CARREIRAS 200
#define MAX_PARAGENS 10000

#define EXTENSAO_INVALIDA 0
#define ANTES_ORIGEM 1
#define DEPOIS_DESTINO 2

/*Corresponde ao número de interseções 
inicialmente alocadas para dada paragem*/
#define N_INI_INTERSECOES 10

typedef struct 
{
    char nome[NOME_P_MAX];
    double latitude;
    double longitude;

    /* Vetor com os nomes das carreiras que se intersetam na paragem */
    char** nomes_carreiras; 

    /* Espaço alocado para o vetor anterior */
    long unsigned int espaco_alocado_intersecao;

    /* Número de carreiras que se intersetam na paragem */
    int num_carreiras;
}Paragem;

/* 'Node' da Linked List que liga as 
diferentes paragens de uma dada carreira */
typedef struct ligacao 
{
    Paragem* atual;
    struct ligacao* proxima;
} Ligacao;

typedef struct
{
    char nome[NOME_C_MAX];
    Paragem* origem;
    Paragem* destino;

    /*Cabeça da Linked list, o seu conteúdo é a paragem de origem 
    e um pointer à seguinte node 'Ligação'*/
    Ligacao* head; 

    int num_stops;
    double custo_total;
    double duracao_total;
} Carreira;

/* Declarações das diferentes funções usadas no programa, 
separadas pelos comandos onde são maioritariamente usadas*/

void free_all();
void free_carreira();

void comando_c(char comando[]);
void comando_p(char comando[]);
void comando_l(char comando[]);
void comando_i();

/* Comando P */
int nome_paragem(char* c, char nome[]);
void lista_paragens();
void print_paragem(char nome_paragem[]);
void cria_paragem(char nome_paragem[], double latitude, double longitude);
int paragem_existe(char nome_paragem[]);

/* Comando C */
void lista_carreiras();
void print_carreira(int n_carreira, int eh_inverso);
void print_carreira_inverso(int n_carreira, Ligacao* head);
void cria_carreira(char nome_carreira[]);
int carreira_existe(char nome_carreira[]);

/* Comando L */
int eh_extensao(int n_carreira,int n_origem,int n_destino);
void adiciona_ligacao(int n_carreira,int n_origem, int n_destino, 
double cost, double duration, int pos_extensao);
Ligacao* ad_ligacao_inicio(int n_paragem, Ligacao** head_prev);
Ligacao* ad_ligacao_final(int n_paragem, Ligacao* head);

/* Comando I */
void adiciona_intersecao(int n_paragem, char nome_intersecao[]);
int intersecao_existe(int n_paragem, char nome_intersecao[]);
void sort_nomes(char** nomes, int length);

#endif
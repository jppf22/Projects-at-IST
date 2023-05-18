#ifndef PROJECT2_H
#define PROJECT2_H

#define FALSE 0
#define TRUE 1

#define MAX_TAMANHO_LINHA 65535

#define EXTENSAO_INVALIDA 0
#define ANTES_ORIGEM 1
#define DEPOIS_DESTINO 2

/*Estrutura que guarda os ponteiros para os primeiros 
e últimos elementos de cada lista de paragens e carreiras*/
typedef struct listas
{
    struct paragem* head_paragens;
    struct paragem* last_paragens;
    struct carreira* head_carreiras;
    struct carreira* last_carreiras;
} Listas;

/* 'Node' da Linked List que liga as 
diferentes carreiras que se intersetam
numa dada paragem */
typedef struct intersecao
{
    struct carreira* atual;
    struct intersecao* proxima;
    struct intersecao* anterior;
} Intersecao;

typedef struct paragem
{
    char* nome;
    double latitude,longitude;

    Intersecao* intersec_head;
    int num_intersecoes;

    struct paragem *next;
    struct paragem *previous;
}Paragem;

/* 'Node' da Linked List que liga as 
diferentes paragens de uma dada carreira */
typedef struct ligacao 
{
    Paragem* atual;
    double custo, duracao;
    struct ligacao* proxima;
    struct ligacao* anterior;
} Ligacao;

typedef struct carreira
{
    char* nome;
    Ligacao* head;
    Ligacao* last;
    int num_stops;
    double custo_total,duracao_total;
    struct carreira *previous, *next; 
} Carreira;


/*Funcao responsavel pela alocacao de memória*/
void *allocate_memory(size_t size, Listas** refs);

/*Funcoes que correm no startup do programa*/
Listas* init();

/*Funcoes que envolvem libertar memoria e suas auxiliares*/
void free_all(Listas** refs, int eh_final);
void free_carreiras(Carreira* head);
void free_ligacoes(Ligacao* head, Carreira* arg_carreira);
void free_paragens(Paragem* head);
void free_intersecoes(Paragem* arg_paragem);
void delete_intersecao(Carreira* arg_carreira,
    Paragem* arg_paragem);
void delete_ligacao(Carreira* arg_carreira, 
    Paragem* arg_paragem);
void empty_carreira(Carreira* arg_carreira);
void remove_ligacao_inicio(Carreira* arg_carreira);
void remove_ligacao_fim(Carreira* arg_carreira);
void remove_ligacao_meio(Carreira* arg_carreira, 
    Ligacao* to_be_deleted);
void delete_carreira(Carreira** to_be_deleted, Listas** ref);
void delete_paragem(Paragem** to_be_deleted, Listas** refs);


/*Funcoes correspondentes aos diferentes comandos*/
void comando_c(char* comando, Listas** refs);
void comando_p(char *comando, Listas** refs);
void comando_l(char* comando, Listas** refs);
void comando_i(Paragem* head);
void comando_r(char* comando, Listas** refs);
void comando_e(char* comando, Listas** refs);

/* Comando P */
char* obter_nome(char** letra_comando,Listas** refs);
void lista_paragens(Paragem* head);
void print_paragem(char* nome_paragem, Paragem* head);
void cria_paragem(char* nome_paragem, double latitude, 
    double longitude, Listas** refs);
Paragem* init_paragem(char* nome_paragem, double latitude, 
    double longitude, Listas** refs);
void adiciona_paragem(Paragem* par, Listas** refs);
Paragem* paragem_existe(char* nome_paragem, Paragem* head);

/* Comando C */
int eh_inverso_certo(char* inverso);
void lista_carreiras(Carreira* head);
void print_carreira(Carreira* arg_carreira, int eh_inverso);
void print_carreira_inverso(Carreira* arg_carreira);
void cria_carreira(char* nome_carreira,Listas** refs);
Carreira* init_carreira(char* nome_carreira, Listas** refs);
void adiciona_carreira(Carreira* car, Listas** refs);
Carreira* carreira_existe(char* nome_carreira, Carreira* head);

/* Comando L */
Carreira* verifica_carreira(char** letra_comando, Listas** refs);
Paragem* verifica_paragem(char** letra_comando, Listas** refs);
int eh_extensao(Carreira* arg_carreira, Paragem* arg_origem,
    Paragem* arg_destino);
void adiciona_ligacao(Carreira* arg_carreira,
    Paragem* arg_origem, Paragem* arg_destino, double custo, 
    double duracao, int pos_extensao, Listas** refs);
void init_ligacao(Carreira* arg_carreira,Paragem* arg_origem, 
    Paragem* arg_destino, double custo, double duracao, 
    Listas** refs);
void ad_ligacao_inicio(Paragem* origem, Ligacao** head_prev, 
    double custo, double duracao,Listas** refs);
void ad_ligacao_final(Paragem* destino, Ligacao** last_prev, 
    double custo, double duracao, Listas** refs);

/* Comando I */
void adiciona_intersecao(Paragem* arg_paragem, 
    Carreira* arg_carreira,Listas** refs);
Intersecao* intersecao_existe(Paragem* arg_paragem, 
    Carreira* arg_carreira);
void sort_nomes_intersecoes(Intersecao** head);
void insert_sorted(Intersecao** head, Intersecao* to_insert);
void lista_intersecoes(Intersecao* head);

#endif
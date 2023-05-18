/*  iaed-23 - ist1106022 - project2

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
r <nome-de-carreira> - remove carreira
e <nome-de-paragem> - elimina paragem
a - apaga todos os dados
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "project2.h"

int main(){

    char* buffer,*comando;
    int termina = FALSE;
    Listas *refs = init();
    buffer = allocate_memory(sizeof(char)*(MAX_TAMANHO_LINHA+1),&refs);
    while (fgets(buffer,MAX_TAMANHO_LINHA,stdin) != NULL){
        comando = allocate_memory(sizeof(char)*(strlen(buffer)+1),&refs);
        if(comando == NULL){
            free(buffer);
            exit(0);
        }
        strcpy(comando,buffer);

        if(comando[0] == 'q') termina = TRUE;
        else if(comando[0] == 'c') comando_c(comando,&refs);
        else if(comando[0] == 'p') comando_p(comando,&refs);
        else if(comando[0] == 'l') comando_l(comando,&refs);
        else if(comando[0] == 'i') comando_i(refs->head_paragens);
        else if(comando[0] == 'r') comando_r(comando,&refs);
        else if(comando[0] == 'e') comando_e(comando, &refs);
        else if(comando[0] == 'a') free_all(&refs,FALSE);

        free(comando);
        if(termina)
            break;
    }
    free(buffer);
    free_all(&refs,TRUE);
    return 0;
}

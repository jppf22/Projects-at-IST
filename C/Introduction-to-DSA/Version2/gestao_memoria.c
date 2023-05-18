/*
Autor: João Fernandes
Descrição: Este ficheiro contém todas as funções relevantes à
alocação e libertação de memória
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "project2.h"

/*Tenta alocar memória e se não o conseguir 
liberta a memória usada pelas 'refs'*/
void *allocate_memory(size_t size, Listas** refs){
    void *p = malloc(size);
    if (p == NULL) {
        printf("No memory.\n");
        free_all(refs,TRUE);
        return NULL;
    }
    return p;
}

/*  Inicializa a estrutura que guarda as listas de paragens e carreiras.
    Incluido neste ficheiro, pois '&refs' que é usado no 'allocate_memory' 
    ainda não existe.   */
Listas* init(){
    Listas *refs = (Listas*) malloc(sizeof(Listas));
    if(refs == NULL){
        printf("No memory.\n");
        exit(0);
    }
    refs->head_carreiras = NULL;
    refs->last_carreiras = NULL;
    refs->head_paragens = NULL;
    refs->last_paragens = NULL;

    return refs;
}

/* Liberta a memória alocada pelo programa, sendo possível libertar 
   o ponteiro para a estrutura Listas (apenas é feito no final do 
   programa ou em caso de não haver memória)    */
void free_all(Listas** refs, int eh_final){
    free_carreiras((*refs)->head_carreiras);
    free_paragens((*refs)->head_paragens);
    (*refs)->head_carreiras = NULL;
    (*refs)->last_carreiras = NULL;
    (*refs)->head_paragens = NULL;
    (*refs)->last_paragens = NULL;
    if(eh_final){
        free(*refs);
        *refs = NULL;
    }
}


/*Remove todas as carreiras da lista de carreiras que começa em 'head'*/
void free_carreiras(Carreira* head){
    Carreira* iter = head;
    while (iter != NULL){
        Carreira* previous = iter;
        iter = iter->next;
        free_ligacoes(previous->head,previous);
        free(previous->nome);
        free(previous);
    }
}

/*  Remove todas as ligacoes da carreira, eliminando também 
da lista de intersecoes de cada paragem esta mesma carreira */
void free_ligacoes(Ligacao* head, Carreira* arg_carreira){
    Ligacao* iter = head;
    while (iter != NULL){
        Ligacao* previous = iter;
        iter = iter->proxima;
        delete_intersecao(arg_carreira,previous->atual);
        free(previous);
    }
}

/*Remove todas as paragens da lista de paragens que começa em 'head'*/
void free_paragens(Paragem* head){
    Paragem* iter = head;
    while (iter != NULL){
        Paragem* previous = iter;
        iter = iter->next;
        free(previous->nome);
        free_intersecoes(previous);
        free(previous);
    }    
}

/*  Remove todas as interseções da paragem dada e,
    nas carreiras cuja interseção foi apagada, apaga qualquer 
    ligação a essa paragem também é removida    */
void free_intersecoes(Paragem* arg_paragem){
    Intersecao* iter = arg_paragem->intersec_head;
    while (iter != NULL){
        Intersecao* previous = iter;
        iter = iter->proxima;
        delete_ligacao(previous->atual,arg_paragem);
        delete_intersecao(previous->atual,arg_paragem);
    }
    
}

/*Remove a carreira da lista de carreiras que se intersem numa dada paragem*/
void delete_intersecao(Carreira* arg_carreira,Paragem* arg_paragem){
    Intersecao* to_be_deleted;
    if((to_be_deleted = intersecao_existe(arg_paragem,arg_carreira)) != NULL){
        if(arg_paragem->intersec_head == to_be_deleted){
            if(arg_paragem->intersec_head->proxima == NULL){
                arg_paragem->intersec_head = NULL;
            }
            else{
                arg_paragem->intersec_head = 
                    arg_paragem->intersec_head->proxima;
            }
        }
        else if(to_be_deleted->proxima == NULL){
            to_be_deleted->anterior->proxima = NULL;
        }
        else{
            to_be_deleted->anterior->proxima = to_be_deleted->proxima;
            to_be_deleted->proxima->anterior = to_be_deleted->anterior;
        }
        free(to_be_deleted);
        arg_paragem->num_intersecoes--;
    }
}

/*Apaga qualquer ligacao à paragem 'arg_paragem' na carreira 'arg_carreira'*/
void delete_ligacao(Carreira* arg_carreira, Paragem* arg_paragem){
    Ligacao* iter = arg_carreira->head;
    while (iter != NULL){
        Ligacao* previous_iter = iter;
        iter = iter->proxima;
        if(previous_iter->atual == arg_paragem){
            if(previous_iter == arg_carreira->head){
                /*Se já só sobrarem duas paragens*/
                if(arg_carreira->head->proxima == arg_carreira->last){
                    if(arg_carreira->last->atual != arg_carreira->head->atual)
                        delete_intersecao(arg_carreira,
                            arg_carreira->last->atual);
                    empty_carreira(arg_carreira);
                    return;
                }
                else
                    remove_ligacao_inicio(arg_carreira);
            }
            else if(previous_iter == arg_carreira->last){
                /*Se já só sobrarem duas paragens*/
                if(arg_carreira->last->anterior == arg_carreira->head){
                    if(arg_carreira->last->atual != arg_carreira->head->atual)
                        delete_intersecao(arg_carreira,
                            arg_carreira->head->atual);
                    empty_carreira(arg_carreira);
                    return;
                }
                else
                    remove_ligacao_fim(arg_carreira); 
            }
            else
                remove_ligacao_meio(arg_carreira,previous_iter);
        }
    }
    
}

/*Elimina as duas paragens restantes de uma carreira*/
void empty_carreira(Carreira* arg_carreira){
    free(arg_carreira->head);
    free(arg_carreira->last);
    arg_carreira->head = NULL;
    arg_carreira->last = NULL;
    arg_carreira->custo_total = 0.0;
    arg_carreira->duracao_total = 0.0;
    arg_carreira->num_stops = 0;
}

/*Elimina a paragem inicial de uma carreira*/
void remove_ligacao_inicio(Carreira* arg_carreira){
    Ligacao* prev_head = arg_carreira->head;
    arg_carreira->head = arg_carreira->head->proxima;
    arg_carreira->head->anterior = NULL;
    arg_carreira->custo_total -= prev_head->custo;
    arg_carreira->duracao_total -= prev_head->duracao;
    arg_carreira->num_stops--;
    free(prev_head);
}

/*Elimina a paragem final de uma carreira*/
void remove_ligacao_fim(Carreira* arg_carreira){
    Ligacao* prev_last = arg_carreira->last;
    arg_carreira->last = arg_carreira->last->anterior;
    arg_carreira->last->proxima = NULL;
    arg_carreira->custo_total -= arg_carreira->last->custo;
    arg_carreira->duracao_total -= arg_carreira->last->duracao;
    arg_carreira->last->duracao = 0.0;
    arg_carreira->last->custo = 0.0;
    arg_carreira->num_stops--;
    free(prev_last);
}

/*Elimina uma paragem intermédia de uma carreira*/
void remove_ligacao_meio(Carreira* arg_carreira, Ligacao* to_be_deleted){
    to_be_deleted->anterior->proxima = to_be_deleted->proxima;
    to_be_deleted->anterior->custo += to_be_deleted->custo;
    to_be_deleted->anterior->duracao += to_be_deleted->duracao;
    to_be_deleted->proxima->anterior = to_be_deleted->anterior;
    arg_carreira->num_stops--;
    free(to_be_deleted);
}

/*Elimina uma carreira da lista de carreiras existentes*/
void delete_carreira(Carreira** to_be_deleted, Listas** ref){
    if((*to_be_deleted)->previous != NULL && 
        (*to_be_deleted)->next != NULL){
        (*to_be_deleted)->previous->next = (*to_be_deleted)->next;
        (*to_be_deleted)->next->previous = (*to_be_deleted)->previous;
    }
    else if((*to_be_deleted)->previous == NULL && 
        (*to_be_deleted)->next == NULL){
        (*ref)->head_carreiras = NULL;
        (*ref)->last_carreiras = NULL;
    }
    else if(*to_be_deleted == (*ref)->head_carreiras){
        (*ref)->head_carreiras = (*ref)->head_carreiras->next;
        (*ref)->head_carreiras->previous = NULL;
    }
    else if(*to_be_deleted == (*ref)->last_carreiras){
        (*ref)->last_carreiras = (*ref)->last_carreiras->previous;
        (*ref)->last_carreiras->next = NULL;
    }
    free_ligacoes((*to_be_deleted)->head,*to_be_deleted);
    free((*to_be_deleted)->nome);
    free(*to_be_deleted);
    *to_be_deleted = NULL; 
}

/*Elimina uma paragem da lista de paragens existentes*/
void delete_paragem(Paragem** to_be_deleted, Listas** refs){
    if((*to_be_deleted)->previous != NULL && 
        (*to_be_deleted)->next != NULL){
        (*to_be_deleted)->previous->next = (*to_be_deleted)->next;
        (*to_be_deleted)->next->previous = (*to_be_deleted)->previous;
    }
    else if((*to_be_deleted)->previous == NULL && 
        (*to_be_deleted)->next == NULL){
        (*refs)->head_paragens = NULL;
        (*refs)->last_paragens = NULL;
    }
    else if(*to_be_deleted == (*refs)->head_paragens){
        (*refs)->head_paragens = (*refs)->head_paragens->next;
        (*refs)->head_paragens->previous = NULL;
    }
    else if(*to_be_deleted == (*refs)->last_paragens){
        (*refs)->last_paragens = (*refs)->last_paragens->previous;
        (*refs)->last_paragens->next = NULL;
    }
    free_intersecoes(*to_be_deleted);
    free((*to_be_deleted)->nome);
    free(*to_be_deleted);
    *to_be_deleted = NULL;
}
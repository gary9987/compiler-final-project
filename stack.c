
#include "stack.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

bool isFull(struct stack *s){
	if(s->tear == MACSTACK-1){
		return true;
	}
	return false;
}
bool isEmpty(struct stack *s){
	return s->tear==s->head ? true:false;
}
int top(struct stack *s){
	return s->arr[s->tear];
}
void push(struct stack *s, int val){
	if(isFull(s)){
		printf("Error, stack full\n");
		exit(1);
	}
	else{
		s->tear++;
		s->arr[s->tear] = val;
	}
}
int pop(struct stack *s) {
	if(isEmpty(s)){
		printf("Stack empty\n");
		return -1;
	}
	else{
		int tmp = s->arr[s->tear];
		s->tear--;
		return tmp;
	}
}
int pop_front(struct stack *s){
	s->head ++;
	int tmp = s->arr[s->head];
	return tmp;
}
#define MACSTACK 100	/* maximum number of symbols */

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct stack {
    int arr[MACSTACK];
	int tear;
    int head;
} for_stack, if_stack, con_stack, while_stack;


bool isFull(struct stack *s);
bool isEmpty(struct stack *s);
int top(struct stack *s);
void push(struct stack *s, int val);
int pop(struct stack *s);
int pop_front(struct stack *s);
%{

 
#include<stdio.h>
 
#include<stdlib.h>
 
#include<string.h>
 
#include<ctype.h>
 
#include<math.h>
 
#define START 100
 
typedef struct 
{	char value[10];
 	int location;
}pqueue;
 

int nextquad=START;
pqueue processQueue[100]; 
char code[25][50];
int qindex=0;
int* Makelist(int nquad)
 
{
 
	int* list=(int*)malloc(sizeof(int)*15);
	 
	list[0]=nquad;
	 
	list[1]=0;
	 
	return list;
	 
}




int* Merge(int* list1,int* list2)
 
{
 
	int i=0,count1=0,count2=0;
	int * temp=(int*)malloc(sizeof(int)*15);
	 
	while( list1!=NULL && list1[count1]!=0) 
	{
		temp[i]=list1[count1];
		count1++;
		i++;

	}
	 
	while(list2!=NULL && list2[count2]!=0)
	 
	{
	 
	temp[i]=list2[count2];
	i++; 
	count2++;
	 
	 
	}

	temp[i]=0;
	return temp;
 
}
int* Merge2(int* list1,int* list2,int* list3,int nquad)
 
{
 
	int i=0,count1=0,count2=0,count3=0;
	int* temp=(int*)malloc(sizeof(int)*25);

	while(list1!=NULL && list1[count1]!=0 ) 
	{
		printf("Inside while1\n");
		temp[i]=list1[count1];
		count1++;
		i++;

	}

	while(list2!=NULL && list2[count2]!=0)
	 
	{
	 
	temp[i]=list2[count2];
	i++; 
	count2++;
	 
	 
	}

	while( list3!=NULL && list3[count3]!=0)
	 
	{
	 
	temp[i]=list3[count3];
	i++; 
	count3++;
	 
	 
	}
	temp[i]=nquad;
	temp[i+1]=0;
	i++;
	return temp;
	 
}
 

void Backpatch(int* list,int nquad)
 
{
 
	char addr[10];
	int i=0;
	sprintf(addr,"%d",nquad);
	 
	while(list!=NULL && list[i]!=0)
	 
	{
	 
	int index=list[i]-START;
	i++;
	strcat(code[index],addr);
	 
	}
 
}

void Gen()
 
{
 
	nextquad++;
 
}
void addQueue(char * arr,int mquad)
{
	strcpy(processQueue[qindex].value,arr);
	processQueue[qindex].location=mquad;
	qindex++;
}
 
%}
 
%code requires { typedef struct s
 
{
 
	int* true;
	 
	int* false;
	 
	int* next;
	 
	int quad;
	 
	char place[5];
 
}ETYPE;
}
 
%union
 
{
 
char id[10];
 
ETYPE eval;
 
}
 
 
 
%left "|"
 
%left "&"
 
%left "!"
 
%left "<" ">"
 
%left "+" "-"
 
%left "*" "/"
 
%left "(" ")"
 
 
 
%right "="
 
 
 
%token <id> LETTER INTEGER FLOAT 
 
%token IF ELSE WHILE FOR DO SWITCH CASE DEFAULT
 
%type <eval> STATEMENTS COND E M N ASSIGN LVAL PROGRAM C      //C is case statement grammar
 
 
 
%start PROGRAM
 

 
%%
PROGRAM: STATEMENTS {int i; for(i=0;i<nextquad-START;i++){printf("%s\n",code[i]);}};
STATEMENTS :/*  IF COND M STATEMENTS {
 Backpatch($2.true,$3.quad);
$$.next = Merge2($4.next,$2.false,NULL,nextquad);
sprintf(code[nextquad-START],"%d\tgoto ",nextquad);

Gen();

}
*/
 COND '?' M STATEMENTS N ':' M STATEMENTS {                  //Ternary operator
	Backpatch($1.true,$3.quad);
	Backpatch($1.false,$7.quad);
	$$.next = Merge2($4.next,$8.next,$5.next,nextquad);
	sprintf(code[nextquad-START],"%d\tgoto ",nextquad);
	Gen();
}
|IF COND M STATEMENTS N ELSE M STATEMENTS {                 //IF Else Statement

	Backpatch($2.true,$3.quad);

	Backpatch($2.false,$7.quad);

	$$.next = Merge2($4.next,$8.next,$5.next,nextquad);

	sprintf(code[nextquad-START],"%d\tgoto ",nextquad);

	Gen();

}

| WHILE M COND M STATEMENTS {
	Backpatch($3.true,$4.quad);
	Backpatch($5.next,$2.quad);
	$$.next = $3.false;
	sprintf(code[nextquad-START],"%d\tgoto %d",nextquad,$2.quad);
	 
	Gen();


}
| DO M STATEMENTS WHILE M COND ';' {

	Backpatch($3.next,$5.quad); 
	Backpatch($6.true,$2.quad); 
	$$.next = $6.false; 

}
| FOR '(' STATEMENTS  M COND ';' M STATEMENTS N ')' M STATEMENTS  {

	Backpatch($3.next,$4.quad); 
	Backpatch($8.next,$4.quad); 
	Backpatch($5.true,$11.quad);
	$$.next = $5.false; 
	Backpatch($12.next,$7.quad);
	sprintf(code[nextquad-START],"%d\tgoto %d",nextquad,$7.quad);
	 
	Gen(); 
	Backpatch($9.next,$4.quad); 

}
|SWITCH '(' E ')' N '{' C '}'
{
	int n,m; // to store the first nquad
        int default_case;
	m=nextquad-START;
	sprintf(code[nextquad-START],"%d\tgoto ",nextquad);      //to get out of switch
		Gen();
	int i;
	for( i=qindex-1 ; i>=0; i--)                       //qindexes is the no. of cases in process Queue
	{
		if(i==qindex-1)
			n=nextquad;
		if(strcmp(processQueue[i].value,"default")==0)
                {
			default_case = processQueue[i].location;
		}
		else {
			sprintf(code[nextquad-START],"%d\tif %s == %s goto %d ",nextquad,$3.place,processQueue[i].value,processQueue[i].location);
		        Gen();
		}
		
			
	}
	sprintf(code[nextquad-START],"%d\telse goto %d ",nextquad,default_case);
	Gen();
	char addr[10];
	sprintf(addr,"%d",nextquad);
	strcat(code[m],addr);
	Backpatch($5.next,n);
}


| '{' STATEMENTS '}' {printf("\n");}
| ASSIGN {                          //To include simple assignment statements in ternary, for eg (a>b) ? x=y : y=z
 

	$$.next=(int*)malloc(sizeof(int)*15);
	 
	$$.next[0]=0;
 
}
| ASSIGN ';' {
 

	$$.next=(int*)malloc(sizeof(int)*15);
	 
	$$.next[0]=0;
 
}
;
COND : '(' COND ')' {
 
	$$.true=$2.true;
	 
	$$.false=$2.false;
	 
}

|COND '&' M COND {
 
	Backpatch($1.true,$3.quad);
	 
	$$.true=$4.true;
	 
	$$.false=Merge($1.false,$4.false);


 
}
|COND '|' M COND {
 
	Backpatch($1.false,$3.quad);
	 
	$$.true=Merge($1.true,$4.true);
	 
	$$.false=$4.false;
 
}
|'!' COND {
 
	$$.true=$2.false;
	 
	$$.false=$2.true;
 
}

|E '>' E { 

	$$.true = Makelist(nextquad);
	$$.false=Makelist(nextquad+1);
	sprintf(code[nextquad-START],"%d\tif %s > %s goto ",nextquad,$1.place,$3.place);
	 
	Gen();
	 
	sprintf(code[nextquad-START],"%d\tgoto ",nextquad);
	 
	Gen();
}
|E '<' E { 

	$$.true = Makelist(nextquad);
	$$.false=Makelist(nextquad+1);
	sprintf(code[nextquad-START],"%d\tif %s < %s goto ",nextquad,$1.place,$3.place);
	 
	Gen();
	 
	sprintf(code[nextquad-START],"%d\tgoto ",nextquad);
	 
	Gen();
};

ASSIGN: LVAL '=' E {

sprintf(code[nextquad-START],"%d\t%s = %s",nextquad,$1.place,$3.place);
 
Gen();
 
};

LVAL: LETTER {strcpy($$.place,$1);};

E : INTEGER{strcpy($$.place,$1); }
  | LETTER {strcpy($$.place,$1); }
  | FLOAT {strcpy($$.place,$1);};

C : CASE E ':' M STATEMENTS C {addQueue($2.place,$4.quad);}    //Case grammar
| CASE E ':' M STATEMENTS {addQueue($2.place,$4.quad);};
| DEFAULT ':' M STATEMENTS {addQueue("default",$3.quad);}


M: {
 
	$$.quad=nextquad;
 
};

N: {
 
	
	$$.next=Makelist(nextquad);

	 
	sprintf(code[nextquad-START],"%d\tgoto ",nextquad);
	 
	Gen();
 
}

%%

int main()
{
	yyparse();
	return 0;
}

void yyerror (char const *s) {
   fprintf (stderr, "%s\n", s);
 }


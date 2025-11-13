# Magyar C++

```bash
flex lexer.l
g++ lex.yy.c
./a.out < fibonacci.txt
```

A Flex file has three sections, separated by %%:

rewrite = to legyen

definitions
%%
rules
%%
user code

SZÁM
VALÓS
+VEKTOR

változódeklarálás, értékadás
összeadás, kivonás, szorzás, osztás (hatványozás? \*\*)
KIÍR, BEOLVAS
HA-AKKOR-KÜLÖNBEN, AMÍG
==, !=, (<, >, <=, >=)
ÉS, VAGY, NEM
hibajelzés, hibaelfedés

+lokális változók
+típuskonverzió
+más, összetettebb feature (sztring interpoláció?)

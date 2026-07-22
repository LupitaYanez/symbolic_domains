* Encoding: UTF-8.
GLM Alg_TR Gra_TR Lex_TR 
  /WSFACTOR = Condicion 3 Polynomial 
  /METHOD = SSTYPE(3) 
  /EMMEANS = TABLES(Condicion) COMPARE ADJ(BONFERRONI) 
  /PRINT = DESCRIPTIVE ETASQ OPOWER 
  /CRITERIA = ALPHA(.05) 
  /WSDESIGN = Condicion.



GLM Alg_Acc Gra_Acc Lex_Acc 
  /WSFACTOR = Condicion 3 Polynomial 
  /METHOD = SSTYPE(3) 
  /EMMEANS = TABLES(Condicion) COMPARE ADJ(BONFERRONI) 
  /PRINT = DESCRIPTIVE ETASQ OPOWER 
  /CRITERIA = ALPHA(.05) 
  /WSDESIGN = Condicion.


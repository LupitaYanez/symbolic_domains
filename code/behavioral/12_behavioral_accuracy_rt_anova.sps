* Encoding: UTF-8.

* -------------------------------------------------------------------------.
* 08_behavioral_accuracy_rt_anova.sps
*
* Purpose:
*   Analyze behavioral performance across stimulus domains.
*
* Analyses:
*   1) Repeated-measures ANOVA for reaction time.
*   2) Repeated-measures ANOVA for accuracy.
*
* Within-subject factor:
*   Domain, with three levels:
*       1 = Algebraic
*       2 = Graphical
*       3 = Lexical
*
* Input variables:
*   Reaction time:
*       Alg_TR
*       Gra_TR
*       Lex_TR
*
*   Accuracy:
*       Alg_Acc
*       Gra_Acc
*       Lex_Acc
*
* Notes:
*   Reaction times are expected to be in seconds.
*   Accuracy values are expected to be percentages.
* -------------------------------------------------------------------------.


* -------------------------------------------------------------------------.
* 1) Reaction time across domains.
* -------------------------------------------------------------------------.

GLM Alg_TR Gra_TR Lex_TR
  /WSFACTOR = Domain 3 Polynomial
  /METHOD = SSTYPE(3)
  /EMMEANS = TABLES(Domain) COMPARE ADJ(BONFERRONI)
  /PRINT = DESCRIPTIVE ETASQ OPOWER
  /CRITERIA = ALPHA(.05)
  /WSDESIGN = Domain.


* -------------------------------------------------------------------------.
* 2) Accuracy across domains.
* -------------------------------------------------------------------------.

GLM Alg_Acc Gra_Acc Lex_Acc
  /WSFACTOR = Domain 3 Polynomial
  /METHOD = SSTYPE(3)
  /EMMEANS = TABLES(Domain) COMPARE ADJ(BONFERRONI)
  /PRINT = DESCRIPTIVE ETASQ OPOWER
  /CRITERIA = ALPHA(.05)
  /WSDESIGN = Domain.
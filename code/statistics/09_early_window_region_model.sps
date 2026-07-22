* Encoding: UTF-8.

* -------------------------------------------------------------------------.
* 09_early_window_region_model.sps
*
* Purpose:
*   Analyze early sensory activity in the 0-180 ms window for the first
*   sequence element (A). This analysis tests whether early activity shows
*   a posterior-to-anterior scalp distribution and whether this distribution
*   differs across stimulus domains.
*
* Input:
*   Wide-format ERP mean-amplitude table exported from ERPLAB for the
*   0-180 ms window.
*
* Required identifier:
*   ERPset
*
* Domains:
*   A = Algebraic
*   G = Graphical
*   L = Lexical
*
* Sequence element:
*   Only element A is analyzed.
*
* ROIs:
*   Occipital: O1/O2
*   Parietal:  P3/Pz/P4
*   Central:   C3/Cz/C4
*   Frontal:   F3/Fz/F4
*
* Models:
*   1) Categorical ROI model:
*      Tests whether early amplitude differs across scalp regions and
*      whether this regional distribution differs by domain.
*
*   2) Ordinal posterior-to-anterior gradient model:
*      Tests for a linear occipital-to-frontal gradient.
*
* RegionOrdinal coding:
*   Occipital = 0
*   Parietal  = 1
*   Central   = 2
*   Frontal   = 3
*
* -------------------------------------------------------------------------.


* -------------------------------------------------------------------------.
* 1) Compute ROI mean amplitudes for element A.
* -------------------------------------------------------------------------.

* Algebraic.
COMPUTE A_Acon_Occ = MEAN(A_Acon_O1, A_Acon_O2).
COMPUTE A_Acon_Par = MEAN(A_Acon_P3, A_Acon_Pz, A_Acon_P4).
COMPUTE A_Acon_Cen = MEAN(A_Acon_C3, A_Acon_Cz, A_Acon_C4).
COMPUTE A_Acon_Fro = MEAN(A_Acon_F3, A_Acon_Fz, A_Acon_F4).

* Graphical.
COMPUTE G_Acon_Occ = MEAN(G_Acon_O1, G_Acon_O2).
COMPUTE G_Acon_Par = MEAN(G_Acon_P3, G_Acon_Pz, G_Acon_P4).
COMPUTE G_Acon_Cen = MEAN(G_Acon_C3, G_Acon_Cz, G_Acon_C4).
COMPUTE G_Acon_Fro = MEAN(G_Acon_F3, G_Acon_Fz, G_Acon_F4).

* Lexical.
COMPUTE L_Acon_Occ = MEAN(L_Acon_O1, L_Acon_O2).
COMPUTE L_Acon_Par = MEAN(L_Acon_P3, L_Acon_Pz, L_Acon_P4).
COMPUTE L_Acon_Cen = MEAN(L_Acon_C3, L_Acon_Cz, L_Acon_C4).
COMPUTE L_Acon_Fro = MEAN(L_Acon_F3, L_Acon_Fz, L_Acon_F4).

EXECUTE.


* -------------------------------------------------------------------------.
* 2) Convert ROI means from wide to long format.
* -------------------------------------------------------------------------.

VARSTOCASES
  /MAKE Y FROM
    A_Acon_Occ A_Acon_Par A_Acon_Cen A_Acon_Fro
    G_Acon_Occ G_Acon_Par G_Acon_Cen G_Acon_Fro
    L_Acon_Occ L_Acon_Par L_Acon_Cen L_Acon_Fro
  /INDEX = Cell(12)
  /KEEP = ERPset
  /NULL = KEEP.

EXECUTE.


* -------------------------------------------------------------------------.
* 3) Create Domain, Region, and RegionOrdinal variables.
* -------------------------------------------------------------------------.

* Domain:
*   1 = Algebraic
*   2 = Graphical
*   3 = Lexical.

DO IF (Cell <= 4).
  COMPUTE Domain = 1.
ELSE IF (Cell <= 8).
  COMPUTE Domain = 2.
ELSE.
  COMPUTE Domain = 3.
END IF.


* Region:
*   1 = Occipital
*   2 = Parietal
*   3 = Central
*   4 = Frontal.

COMPUTE Region = MOD(Cell - 1, 4) + 1.


* Ordinal posterior-to-anterior predictor:
*   Occipital = 0
*   Parietal  = 1
*   Central   = 2
*   Frontal   = 3.

COMPUTE RegionOrdinal = Region - 1.


VALUE LABELS Domain
  1 'Algebraic'
  2 'Graphical'
  3 'Lexical'.

VALUE LABELS Region
  1 'Occipital'
  2 'Parietal'
  3 'Central'
  4 'Frontal'.

EXECUTE.


* -------------------------------------------------------------------------.
* 4) Model 1: Categorical region model.
*
* This model tests whether early activity differs across scalp regions and
* whether this regional distribution depends on stimulus domain.
* -------------------------------------------------------------------------.

MIXED Y BY Domain Region
  /FIXED = Domain Region Domain*Region | SSTYPE(3)
  /METHOD = REML
  /RANDOM = INTERCEPT | SUBJECT(ERPset) COVTYPE(VC)
  /PRINT = SOLUTION TESTCOV.


* -------------------------------------------------------------------------.
* 5) Model 2: Ordinal posterior-to-anterior gradient model.
*
* This model tests whether early activity decreases linearly from posterior
* to anterior regions.
* -------------------------------------------------------------------------.

MIXED Y BY Domain
  WITH RegionOrdinal
  /FIXED = Domain RegionOrdinal Domain*RegionOrdinal | SSTYPE(3)
  /METHOD = REML
  /RANDOM = INTERCEPT | SUBJECT(ERPset) COVTYPE(VC)
  /PRINT = SOLUTION TESTCOV.
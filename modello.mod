
# VARIABILI

# Insieme dei cuochi che si candidano per partecipare alla cena di Gala
set cuochi;

# Insieme delle portate realizzate dai cuochi nelle prove e che dovranno essere realizzate durante la cena di Gala
set portate;

# Insieme delle persone (non cuochi) che vengono assunte dal ristorante per la cena
set personale;




# PARAMETRI 

# numero di cuochi necessari per la portata in portate
param necessita{portate};

# voto attribuito al cuoco appartenente a cuochi nella portata appartenente a portate
param voto{cuochi, portate};

# compenso promesso al cuoco in cuochi per ogni portata che realizza
param compenso{cuochi};

# stipendio promesso al personale in personale
param stipendio{personale};

# numero massimo di portate che ogni cuoco può realizzare
param maxPortate;

# surplus previsto per l'eventuale cuoco che realizzerà la portata aggiuntiva
param surplus;

# numero di portate totali
param portateTotali;

# budget totale a disposizione del ristorante per pagare cuochi e personale
param budgetTotale;

# BigM
param BigM;

# voto medio che deve avere il dessert
param votoMedioDessert;

# VARIABILI 

# 1: se il cuoco in cuochi cucina la portata in portate
# 0: altrimenti
var x{cuochi, portate} binary;

# 1: se il cuoco in cuochi prepara almeno una portata
# 0: altrimenti 
var y{cuochi} binary;

# 1: se il cuoco in cuochi prepara una portata aggiuntiva
# 0: altrimenti
var w{cuochi} binary;

# 1: se il cuoco in cuochi prepara il dessert
# 0: altrimenti
var u{cuochi} binary;

# quantità di personale in personale assunto
var z{personale} >=0 integer;



# MODELLO 

# funzione obiettivo
maximize voto_medio : sum{j in portate} ((sum{ i in cuochi} x[i,j]*voto[i,j])/necessita[j])/portateTotali;

# numero di cuochi necessari per realizzare ciascuna portata
s.t. cuochi_richiesti{j in portate}: sum{i in cuochi} x[i,j] <= necessita[j];

s.t. cuochi_richiesti2{j in portate}: sum{i in cuochi} x[i,j] >= necessita[j];

# massimo numero di portate che ogni cuoco può realizzare
s.t. max_portate{ i in cuochi}: sum{j in portate} x[i,j] <= maxPortate + w[i];

# al più un cuoco può realizzare una portata aggiuntiva
s.t. max_portate_aggiuntive : sum{i in cuochi} w[i] <= 1;

# budget massimo a disposizione del ristorante
s.t.  budget_totale: sum{i in cuochi} sum{j in portate} x[i,j]* compenso[i] + sum{k in personale} stipendio[k]*z[k] + sum {i in cuochi} surplus*w[i] <= budgetTotale;

# attivazione della variabile y per determinare chi partecipa alla cena
s.t. cuochi_totali{ i in cuochi}: BigM * y[i] >= sum{j in portate}x[i,j];

# gli addetti al personale devono essere almeno il doppio del numero di cuochi
s.t. addetti_personale: sum{ k in personale} z[k] >= 2* sum{i in cuochi} y[i];

# il numero di camerieri assunti deve essere almeno 2/3 del numero di aiuto cuochi
s.t. richiesta_camerieri: z["cameriere"] >= 2/3 * z["aiuto cuoco"];

# attivazione variabile u per determinare chi prepari il dessert 
s.t. cuochi_dessert{ i in cuochi}: u[i] >= x[i,"dessert"];

# un cuoco che prepara il dessert non può dedicarsi ad altre portate
s.t. cuochi_non_dessert{i in cuochi} : (portateTotali -1)*(1-u[i]) >= sum{j in portate: j <> "dessert"} x[i,j];

# il voto medio di coloro che preparano il dessert deve essere superiore a votoDessert
s.t. voto_medio_dessert: (sum{i in cuochi} x[i,"dessert"]* voto[i,"dessert"]) /necessita["dessert"] >= votoMedioDessert;

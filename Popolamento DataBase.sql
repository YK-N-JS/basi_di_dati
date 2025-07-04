--Popolamento User:

insert into "user" (username, "Password") values
('Davide', 'Davide'),
('Giulia', 'Giulia'),
('Silvio', 'Silvio'),
('Porfirio', 'Porfirio');


--Popolamento bacheca: non è stato ritenuto necessario inserire a mano delle bacheche, in quanto già inserite dalla
--funzione "createDefaultBachecheFunction" dopo l'inserimento di un utente.


--Popolamento ToDo:
--Per i ToDo è stato ritenuto superfluo inserire valori per i campi "icon" e "color", in quanto non hanno un vero utilizzo
--al di fuori dell'interfaccia grafica e hanno un valore di default. Il valore "expired" è gestito automaticamente dal database,
--quindi non è necessario inserire manualmente neanche quello.

insert into todo (title, url, description, "Owner", complete_By_Date, completed)
values
('Studiare', 'https://youtu.be/dQw4w9WgXcQ?si=jf-cwJ4iZyXNxaN', 'Studiare le ~cose~', 'Davide', '2025-6-23', true),
('Completare il pokédex', 'https://www.pokemon.com/it/pokedex', 'Trovare Shaymin e Manaphy', 'Giulia', '2026-1-31', false),
('Riposare', 'https://open.spotify.com/playlist/37i9dQZF1DXbITWG1ZJKYt?si=rHt_8ebFSza7e1UT__J4cQ', 'Ascolta i grandi classici del Jazz per riposarti', 'Porfirio', '2025-6-30', false),
('Correggere le prove intercorso', 'http://localhost:8080/', 'Correggere la seconda prova intercorso di Basi di dati I', 'Silvio', '2025-6-23', true),
('Mangiare', 'http://mangiaresano.wolrd/', 'Mangiare sempre tanta frutta e verdura', 'Porfirio', '2000-01-01', true),
('Bere', 'http://beresano.wolrd/', 'Almeno due litri di acqua al giorno', 'Silvio', '3000-01-01', false),
('Fare esercizio fisico regolarmente', 'http://esercitaresano.wolrd/', 'Almeno 30 minuti al giorno', 'Davide', '4000-01-01', false),
('Sopravvivere', 'http://viveresano.wolrd/', 'Non morire', 'Giulia', '5000-01-01', false);


--Popolamento Placement:
--Le placement sono state inserite manualmente dato che le funzioni di inserzione e di condivisione necessitano di dati
--non facilmente reperibili da Postgres. Le funzioni menzionate sono infatti ottimizzate per un utilizzo lato JAVA.

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca."Owner" LIKE 'Silvio' and bacheca.title like 'Lavoro' and todo.title like 'Correggere le prove intercorso';

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca."Owner" LIKE 'Porfirio' and bacheca.isdefault = true and todo.title like 'Correggere le prove intercorso';

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca."Owner" LIKE 'Davide' and bacheca.title like 'Università' and todo.title like 'Studiare';

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca."Owner" LIKE 'Giulia' and bacheca.isdefault = true and todo.title like 'Studiare';

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca."Owner" LIKE 'Giulia' and bacheca.title like 'Tempo libero' and todo.title like 'Completare il pokédex';

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca."Owner" LIKE 'Davide' and bacheca.isdefault = true and todo.title like 'Completare il pokédex';

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca."Owner" LIKE 'Porfirio' and bacheca.title like 'Tempo libero' and todo.title like 'Riposare';

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca."Owner" LIKE 'Silvio' and bacheca.isdefault = true and todo.title like 'Riposare';

insert into placement (idbacheca, idtodo)
select bacheca."ID", todo."ID"
from bacheca, todo
where bacheca.isdefault = true and (todo.title like 'Mangiare' OR todo.title like 'Bere' OR todo.title like 'Fare esercizio fisico regolarmente' or todo.title like 'Sopravvivere');
% ahmet mert tahran
% 2016400060 
% compiling: yes
% complete: yes

:- [pokemon_data]. % to include data file
% find_pokemon_evolution(+PokemonLevel, +Pokemon, -EvolvedPokemon)
find_pokemon_evolution(PokemonLevel, Pokemon, EvolvedPokemon):- %search mechanism to find evolved version of the pokemon.
		pokemon_evolution(Pokemon,Temp,X), PokemonLevel >= X -> %to control if evolution of the pokemon exist in knowledge base
		find_pokemon_evolution(PokemonLevel,Temp,EvolvedPokemon); %to check whether extra evolutions occur 
		pokemon_stats(Pokemon,_,_,_,_),EvolvedPokemon=Pokemon.	%if the pokemon which exist cannot evolve return itself(?).	
		
%pokemon level stats(+PokemonLevel, ?Pokemon, -PokemonHp, -PokemonAttack, -PokemonDefense)	
pokemon_level_stats(Level,Pokemon,Hp,Attack,Defense):- % To find a pokemon's stats which has "Level" level
		pokemon_stats(Pokemon,_,Hp1,Attack1,Defense1),%to find the pokemon's base points
		(Hp2 is 2*Level,Hp is Hp1+Hp2),  % to calculate health point
		Attack is Attack1+Level,		% to calculate attack point
		Defense is Defense1+Level.		% to calculate defense point
		
%single type multiplier(?AttackerType, ?DefenderType, ?Multiplier)
single_type_multiplier(AttackerType, DefenderType, Multiplier):- %to find attack mutiplier when AttackerType
		type_chart_attack(AttackerType, Multipliers),			% attacks the DefenderType 
		pokemon_types(T),  										% T is TypeList
		find_multiplier(DefenderType,T,Multiplier,Multipliers).
		
%find_multiplier(?Type,+TypeList,?Multiplier,+MultiplierList)
find_multiplier(Type,[X|L],Multiplier,[X2|L2]):-%helper function to find multiplier from knowledge base
	Type=X , Multiplier=X2; 	% to iterate lists together 1:1
	find_multiplier(Type,L,Multiplier,L2). %recursive part

%type_multiplier(?AttackerType, +DefenderTypeList, ?CumulativeMultiplier)
type_multiplier(_, [], 1).% ı choose if the DefenderTypeList is empty return 1, it did not mentioned in project description
type_multiplier(Type, [X|L], CumMul):-%to find cumulative multiplier of attacker type to defender's types
	single_type_multiplier(Type, X, Mul),%to find type multiplier one by one
	type_multiplier(Type, L, Mul2), %recursive part
	CumMul is Mul * Mul2. % to cumulate multiplier
		
	
%pokemon_type_multiplier(?AttackerPokemon, ?DefenderPokemon, ?Multiplier)
pokemon_type_multiplier(Attacker, Defender, Mul):- % to calculate attack multiplier ofattacker pokemon to defender pokemon
	pokemon_stats(Attacker,Types,_,_,_), %to access attacker pokemon's types
	pokemon_stats(Defender,Types2,_,_,_),% to access defender pokemon's types.
	search_multiplier(Types,Types2,Mul).%to find attack mutiplier of Attacker to Defender
	
%search_multiplier(+AttackerTypes,+DefenderTypes,-Max)	
search_multiplier([],_,0.0).
search_multiplier([Head|Tail],DefenderTypes,Max):-%to find attack mutiplier when AttackerTypes
	type_multiplier(Head, DefenderTypes, Mul),	  %attacks the DefenderTypes
	search_multiplier(Tail,DefenderTypes,Mult), %recursive part
	select_max(Mul,Mult,Max). %to find max of Multipliers

%select_max(select_max(FirstElement,SecondElement,Max)
select_max([],[],0.0).%fixed point about list's situation to find max
select_max([],SecondElement,SecondElement).	%fixed point about list's situation to find max
select_max(FirstElement,[],FirstElement).%fixed point about list's situation to find max
select_max(FirstElement,SecondElement,Max):-% to find max of two element
	FirstElement>SecondElement -> Max = FirstElement; %check condition of being greater
	Max=SecondElement.
	
%pokemon_attack(+AttackerPokemon, +AttackerPokemonLevel, +DefenderPokemon,+DefenderPokemonLevel, -Damage)
pokemon_attack(Attacker, AttackerLevel, Defender,DefenderLevel, Damage):-%to find damage to DefenderPokemon
	pokemon_level_stats(AttackerLevel,Attacker,_,Attack,_), %to access attack point of attacker pokemon
	pokemon_level_stats(DefenderLevel,Defender,_,_,Defense),%to access defense point of defender pokemon
	pokemon_type_multiplier(Attacker, Defender, Mul), % to find attack multiplier of attacker pokemon to defender pokemon 
	Damage is AttackerLevel*Attack*Mul*0.5/Defense+1.% the formula about damage in project description
	
	
%pokemon_fight(+Pokemon1, +Pokemon1Level, +Pokemon2, +Pokemon2Level,-Pokemon1Hp, -Pokemon2Hp, -Rounds)
pokemon_fight(P1, P1Level, P2, P2Level,P1Hp, P2Hp, Rounds):-
	pokemon_attack(P1, P1Level, P2, P2Level, Damage1), % ı may have some error due to this calcualtion
	pokemon_attack(P2, P2Level, P1, P1Level, Damage2),% ı may have some error due to this calcualtion
	pokemon_level_stats(P1Level,P1,HP1,_,_),		%to access initial Health Points of Pokemon1
	pokemon_level_stats(P2Level,P2,HP2,_,_),		%to access initial Health Points of Pokemon2
	find_round(HP1,HP2,Damage1,Damage2,Rounds,P1Hp,P2Hp).%to find the Remaining HPs and # of round

%find_round(+Pokemon1Hp,+Pokemon2Hp,+Pokemon1Damage,+Pokemon2Damage,-Rounds,-Pokemon1LastHp,-Pokemon2LastHp)
find_round(HP1,HP2,Damage1,Damage2,Rounds,LHP1,LHP2):-%to find the Remaining HPs and # of round
	THP1 is HP1 -Damage2, %to calculate remaining HP
	THP2 is HP2 -Damage1,%to calculate remaining HP
	(THP2>0,THP1>0 -> % to control end condition
	find_round(THP1,THP2,Damage1,Damage2,Round,LHP1,LHP2), Rounds is Round+1;%recursive part
	 Rounds is 1, LHP1 is THP1, LHP2 is THP2).	%base case
	 
%pokemon_fight2(+Pokemon1, +Pokemon1Level, +Pokemon2, +Pokemon2Level,-Pokemon1Hp, -Pokemon2Hp, -Rounds)
pokemon_fight2(P1, P1Level, P2, P2Level,P1Hp, P2Hp, Round):-%to find the # of round and reamining health points of Pokemons
	pokemon_attack(P1, P1Level, P2, P2Level, Damage1),		%to find damage to Pokemon2 by Pokemon1
	pokemon_attack(P2, P2Level, P1, P1Level, Damage2),		%to find damage to Pokemon1 by Pokemon2
	pokemon_level_stats(P1Level,P1,HP1,_,_),				%to access initial Health Points of Pokemon1
	pokemon_level_stats(P2Level,P2,HP2,_,_),				%to access initial Health Points of Pokemon2
	find_round2(HP1,HP2,Damage1,Damage2,Round,P1Hp,P2Hp).%to find # of round  and reamining HP of Pokemons
	%precalculation of Damage1 and Damage2 can cause error.

%find_round2(+Pokemon1Hp,+Pokemon2Hp,+Pokemon1Damage,+Pokemon2Damage,-Round,-Pokemon1LastHp,-Pokemon2LastHp)
find_round2(HP1,HP2,Damage1,Damage2,Rounds,LHP1,LHP2):-%to find the Remaining HPs and # of round
	Round1 is ceiling(HP1/Damage2),%to find one option of # of rounds - this calculation may cause extra error
	Round2 is ceiling(HP2/Damage1),%to find one option of # of rounds
	(Round1> Round2 -> % to select which one is min 
	Rounds is Round2,
	LHP1 is HP1 - Damage2 * Round2, %to calculate remaining HP
	LHP2 is HP2 - Damage1*Round2;	%to calculate remaining HP		
	Rounds is Round1,	
	LHP1 is HP1 - Damage2 * Round1,%to calculate remaining HP
	LHP2 is HP2 - Damage1*Round1).%to calculate remaining HP
	
% pokemon_tournament(+PokemonTrainer1, +PokemonTrainer2, -WinnerTrainerList)
pokemon_tournament(Trainer1, Trainer2, WinnerList):-
	pokemon_trainer(Trainer1, Team1, Levels1),%to access pokemonlist of Trainer1 and their own level
	pokemon_trainer(Trainer2, Team2, Levels2),%to access pokemonlist of Trainer2 and their own level
	team_update(Team1,Levels1,UTeam1),%to check if each pokemon can evolve, and accordingly force it to evolve.
	team_update(Team2,Levels2,UTeam2),%to check if each pokemon can evolve, and accordingly force it to evolve.
	winner_list(Trainer1,Trainer2,UTeam1,Levels1,UTeam2,Levels2,WinnerList).%to find WinnerList with updated pokemons
	
%team_update(+Team,+Levels,-UpdatedTeam)	
team_update([],_,[]).%base case
team_update([P1|PTail],[L1|LTail],[NewX|UTail]):-%to check if each pokemon can evolve, and accordingly force it to evolve.
	find_pokemon_evolution(L1,P1,NewX), %to find evolved version if it does
	team_update(PTail,LTail,UTail).%recursive part
	
%winner_list(+Trainer1,+Trainer2,+Team1,+LevelsofTeam1,+Team2,+LevelsofTeam2,-WinnerList)
winner_list(_,_,[],[],[],[],[]).%base case
winner_list(Trainer1,Trainer2,[T1|Tail1],[L1|LTail1],[T2|Tail2],[L2|LTail2],[W1|WTail]):-%to find WinnerList
	pokemon_fight(T1,L1,T2,L2,HP1,HP2,_), %to find RemainingHPs of the fighting pokemons
	(HP1>=HP2 -> % to check which win this fight
	W1 = Trainer1;W1 = Trainer2 ), % to update WinnerList
	winner_list(Trainer1,Trainer2,Tail1,LTail1,Tail2,LTail2,WTail). %recursive part
	
%best_pokemon(+EnemyPokemon, +LevelCap, -RemainingHP, -BestPokemon)
best_pokemon(Enemy, LevelCap, RemainingHP, BestPokemon):-% to find the pokemon which have the most HP after fight with EnemyPokemon.
	findall(Best,(pokemon_stats(Best,_,_,_,_),pokemon_fight(Enemy,LevelCap,Best,LevelCap,HPenemy,HP,R),HP>HPenemy),BestList),% to find pokemon's Hp after the fight	
	findall(BestHP,(pokemon_stats(Best,_,_,_,_),pokemon_fight(Enemy,LevelCap,Best,LevelCap,HP,BestHP,R),BestHP>HP),BestHPList),% to find pokemon's Hp after the fight	
	sort(BestHPList,Sorted),last(Sorted,RemainingHP),%to find max RemainingHP
	find_multiplier(RemainingHP,BestHPList,BestPokemon,BestList).% to find BestPokemon

%best_pokemon_team(+OpponentTrainer, -PokemonTeam)
best_pokemon_team(Opponent, MyTeam):-%to find BestTeam to OpponentTrainer when there is no restriction
	pokemon_trainer(Opponent,TeamList,Levels),%to access OpponentTrainer's pokemonlist and each pokemon's own level in another List 
	best_pokemon_team2(TeamList,Levels,MyTeam). %to find BestTeam according to these data.

%best_pokemon_team2(+OpponentTrainerPokemonList,+OpponentTrainerPokemonLevelList, -PokemonTeam)
best_pokemon_team2([],_,[]).%base case.
best_pokemon_team2([O1|Os],[L1|Ls], [M1|Ms]):-%to find BestTeam to OpponentTrainer's Pokemons
	best_pokemon(O1,L1,_,M1),%to find best pokemon to Nth pokemon of OpponentTrainer
	best_pokemon_team2(Os,Ls,Ms).%recursive part

%pokemon_types(+TypeList, +InitialPokemonList, -PokemonList)
pokemon_types(TypeList, InitialPokemonList, PokemonList):-%to filter the list acc to TypeList
	findall(Pokemon,(member(Pokemon,InitialPokemonList),pokemon_types2(TypeList,Pokemon)),PokemonList).
%pokemon_types2(+TypeList,+Pokemon)
pokemon_types2([H|Tail],Pokemon):-%to check the pokemon has one of the expected types
	pokemon_stats(Pokemon,TList,_,_,_),%to access TypeList of the pokemon
	((member(H,TList),! ); %to check the pokemon has one of the expected types
	pokemon_types2(Tail,Pokemon)).%recursive part

%ismember(+Unknown,+Controllers)
pokemon_types3([H|Tail],ControlList):-%to check the pokemon has one of the expected types
	not(member(H,ControlList)), %to check the pokemon has one of the expected types
	pokemon_types3(Tail,ControlList).%recursive part
pokemon_types3([],_):- true.%base case

%append_times(Times,List,NewList)
append_times(Times,[L1|Tail1],[N1|T]):-%% to add desired number of element to the NewList from the List
	N1 = L1, Time is Times -1, append_times(Time,Tail1,T). 
append_times(0,_,[]).%base case


conditiona(R,[_,_,N1,_],[_,_,N2,_]) :-  N1=\=N2, !,compare(R,N2,N1).%to sort descending order according to attack points
conditiona(R,N2,N1) :- compare(R,N2,N1).% not to delete duplicates in terms of attack points
conditiond(R,[_,_,_,N1],[_,_,_,N2]) :-  N1=\=N2, !,compare(R,N2,N1).%to sort descending order according to defense points
conditiond(R,N2,N1) :- compare(R,N2,N1).% not to delete duplicates in terms of defense points
conditionh(R,[_,N1,_,_],[_,N2,_,_]) :-  N1=\=N2, !,compare(R,N2,N1).%to sort descending order according to health points
conditionh(R,N2,N1) :- compare(R,N2,N1).% not to delete duplicates in terms of health points

%generate_pokemon_team(+LikedTypes, +DislikedTypes, +Criterion, +Count,-PokemonTeam)
generate_pokemon_team(Likes, Dislikes, Criterion, Count,PokemonTeam):-
	not(Likes = Dislikes),%to be faster
	findall(P,(pokemon_stats(P,Types,_,_,_),pokemon_types3(Types,Dislikes)),NonDislikes),%to filter pokemons
	pokemon_types(Likes,NonDislikes,PokeList),%to filter liked ones
	findall([Y,HP,AP,DP],(member(Y,PokeList),pokemon_stats(Y,_,HP,AP,DP)),Filtered),%to filter pokemons
	(Criterion = h -> predsort(conditionh,Filtered, Sorted); %to sort pokemons interms of health points
	Criterion = a -> predsort(conditiona,Filtered, Sorted);%to sort pokemons interms of attack points
	Criterion = d -> predsort(conditiond,Filtered, Sorted)),%to sort pokemons interms of defense points
	append_times(Count,Sorted,PokemonTeam). % to add the list desired number of pokemons

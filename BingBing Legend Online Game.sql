--STUDENT 1 code
--1 List the names and emails of all players whose names contain the strings ‘er’ or ‘on’. Arrange the list alphabetically according to the names.
SELECT P.Player_Name,A.Email 
FROM Player P INNER JOIN Account A ON P.AccountID= A.AccountID
WHERE P.Player_Name LIKE '%er%' or P.Player_Name LIKE '%on%'

--2 List the details of players who own any heroes whose levels are more than 3. 
SELECT DISTINCT P.AccountID,P.Player_Name,P.Birth_date,A.Username,A.Email,A.Diamonds,A.Battle_Points,A.Global_level,A.Games_played,A.Online_Status
FROM Player P INNER JOIN Player_Hero H ON P.PlayerId= H.PlayerId INNER JOIN Account A ON P.AccountID= A.AccountID
WHERE H.Current_level > 3

--3 List the ids, names and levels of all heroes owned by the player named ‘Wade Wilson’.
SELECT P.PlayerId,X.Hero_Name,H.Current_level
FROM Player P INNER JOIN Player_Hero H ON P.PlayerId= H.PlayerId INNER JOIN Hero X ON X.Hero_Id=H.Hero_Id 
WHERE P.Player_Name = 'Wade Wilson'

--Student 2
--1.	List, in chronological order of game date, the game ids and dates for all games played between ‘01/02/2020’ and ‘29/02/2020’.
SELECT Game_date,Game_Id
FROM Game
WHERE Game_date between '2020-02-01' and '2020-02-29'
ORDER BY Game_date ASC; 

--2.	List the names and email addresses of all players who own any ‘Assassin’ role type heroes. 
SELECT P.Player_Name, A.Email
FROM Player P INNER JOIN Player_Hero H ON P.PlayerId= H.PlayerId INNER JOIN Hero X ON X.Hero_Id=H.Hero_Id INNER JOIN Account A ON P.AccountID=A.AccountID
WHERE X.Hero_Role= 'Assassin'

--3.	List the ids and names of all heroes who has any skin priced higher than the average price of all skins. 
SELECT H.Hero_Id , H.Hero_Name
FROM Hero H INNER JOIN Skin S ON H.Hero_Id=S.Hero_Id 
WHERE S.Skin_Price > (SELECT Avg(Skin_Price) FROM Skin)

--Student 3
--1.	List the names and email addresses of all players who have collected at least 15 diamonds. Arrange the list alphabetically according to the names. 
SELECT P.Player_Name, A.Email
FROM Player P INNER JOIN Account A ON P.AccountID=A.AccountID
WHERE A.Diamonds >= 15  
ORDER BY P.Player_Name ASC;

--2.	List the hero id, hero name and total number of skins belonging to each hero. 
SELECT H.Hero_Id, H.Hero_Name,COUNT(S.Skin_Id) AS 'Total Number of Skins' 
FROM Hero H INNER JOIN Skin S ON H.Hero_Id=S.Hero_Id 
GROUP BY H.Hero_Id, H.Hero_Name

--3.	List the details of all players whose global levels exceed 5 and have played more than 3 games. 
SELECT P.AccountID,P.Player_Name,P.Birth_date,A.Username,A.Email,A.Diamonds,A.Battle_Points,A.Global_level,A.Games_played,A.Online_Status
FROM Player P INNER JOIN Account A ON P.AccountID=A.AccountID
WHERE A.Global_level > 5 AND A.Games_played > 3

--Student 4
--1.	List the names and battle points of all players with the highest battle points. Arrange the list alphabetically according to the names. 
SELECT P.Player_Name,A.Battle_Points
FROM Player P INNER JOIN Account A ON P.AccountID=A.AccountID
WHERE A.Battle_Points = (SELECT MAX(Battle_Points)FROM Account)
ORDER BY P.Player_Name ASC;
--2.	List the total number of games played in each game mode. Sort your answer in descending order of total number of games played. 
SELECT M.Arena, COUNT(G.ArenaID) AS 'total number of games played'
FROM Game G INNER JOIN Game_Mode M ON G.ArenaID=M.ArenaID
GROUP BY M.Arena

--3.	List the ids and names of the most used heroes for the player named ‘Steve Rogers’.
SELECT TOP 1 H.Hero_Id,H.Hero_Name
FROM Player P INNER JOIN Game G ON P.AccountID = G.AccountID INNER JOIN Hero H ON H.Hero_Id = G.Hero_Id
WHERE P.Player_Name= 'Steve Rogers' 
-- 1. List the names of all pet owners along with the names of their pets. 

select po.OwnerID, concat(po.`Name`," ", po.Surname) as Owner_name, pt.Kind, pt.`Name`
from petowners po
LEFT JOIN pets pt on po.OwnerID=pt.OwnerID; 

-- 2. List all pets and their owner names, including pets that don't have recorded owners. 

select pt.OwnerID, pt.`Name`, pt.Kind, concat(po.`Name`, ' ' , po.Surname) as Pet_owner_names
from pets pt 
LEFT JOIN petowners po ON pt.OwnerID = po.OwnerID ;

-- 3. Combine the information of pets and their owners, including those pets without owners and owners without pets.
select po.OwnerID, concat(po.`Name`," ", po.Surname) as Owner_name, pt.Kind, pt.`Name`
from petowners po
Left join pets pt ON pt.OwnerID = po.OwnerID
UNION 
select po.OwnerID, concat(po.`Name`," ", po.Surname) as Owner_name, pt.Kind, pt.`Name`
from pets pt
Left join petowners po ON pt.OwnerID = po.OwnerID; 

-- 4. Find the names of pets along with their owners' names and the details of the procedures they have undergone. 

select p.PetID, p.`Name` as pet_name ,concat(po.`Name`, ' ' , po.Surname) AS Pet_owners_name , ph.ProcedureType
from pets p
LEFT JOIN petowners po ON p.OwnerID= po.OwnerID
LEFT JOIN procedureshistory ph ON p.PetID= ph.PetID ;


-- 5. List all pet owners and the number of dogs they own. 

select concat(po.`Name`, ' ', po.Surname) as Pet_owner_name, count(p.Kind) as dogs_owned 
from petowners po
LEFT JOIN pets p ON po.OwnerID= P.OwnerID
where p.Kind = 'Dog' 
group by Pet_owner_name ;


-- 6. Identify pets that have not had any procedures 

select p.PetID, p.`Name`, p.Kind, ph.ProcedureType
from pets p 
LEFT JOIN procedureshistory ph ON p.PetID= ph.PetID 
where ProcedureType is NULL ; 


-- 7 . Find the name of the oldest pet. 

select  p.PetID, p.`Name`, p.Kind, p.Gender, max(p.Age) AS Oldest_pet
from pets p
group by p.PetID, p.`Name`, p.Kind, p.Gender
order by Oldest_pet DESC
LIMIT 3;


--  8. List all pets who had procedures that cost more than the average cost of all procedures ( NOTE: i dint calculated average for each category alone, however i took overall average) 

select p.PetID, p.`Name`, p.Kind, p.Gender, ph.ProcedureType, pd.Price
from pets p
left join procedureshistory ph on p.PetID= ph.PetID 
left join proceduresdetails pd on pd.ProcedureType = ph.ProcedureType and pd.ProcedureSubCode=ph.ProcedureSubCode
where ph.ProcedureType is NOT NULL and pd.Price > (select avg(Price) AS average_priceof_procedure from proceduresdetails) ;


-- 9. Find the details of procedures performed on 'Cuddles'

select * 
from pets p 
LEFT JOIN procedureshistory ph on p.PetID = ph.PetID
left join proceduresdetails pd on pd.ProcedureType = ph.ProcedureType and pd.ProcedureSubCode=ph.ProcedureSubCode 
where p.`Name` = 'Cuddles';  

-- 10. Create a list of pet owners along with the total cost they have spent on  procedures and display only those who have spent above the average spending. 


select concat(po.`Name`, ' ', po.Surname) as owner_name, sum(pd.Price) as total_cost_on_procedures
from petowners po 
LEFT JOIN pets p on po.OwnerID = p.OwnerID 
LEFT JOIN procedureshistory ph on ph.PetID = p.PetID
left join proceduresdetails pd on pd.ProcedureType = ph.ProcedureType and pd.ProcedureSubCode=ph.ProcedureSubCode
group by owner_name 
HAVING total_cost_on_procedures > ( SELECT AVG(total_price_spent) FROM
														(SELECT 
                                                        po.OwnerID, SUM(pd.Price) AS total_price_spent
														FROM
														petowners po
														LEFT JOIN pets p ON po.OwnerID = p.OwnerID
														LEFT JOIN procedureshistory ph ON ph.PetID = p.PetID
														LEFT JOIN proceduresdetails pd ON pd.ProcedureType = ph.ProcedureType
															  AND pd.ProcedureSubCode = ph.ProcedureSubCode
														GROUP BY po.OwnerID) AS average_cost_table ) ;
                                                        
-- 11. List the pets who have undergone a procedure called 'VACCINATIONS'. 

select p.PetID, p.`Name`
from pets p 
LEFT JOIN procedureshistory ph on p.PetID= ph.PetID
where ph.ProcedureType = 'VACCINATIONS';



-- 12. Find the owners of pets who have had a procedure called 'EMERGENCY'. 
select concat(po.`Name`,' ', po.Surname) as Owners_name
from petowners po 
LEFT JOIN pets p on po.OwnerID = p.OwnerID
LEFT JOIN procedureshistory ph on ph.PetID = p.PetID
WHERE ph.ProcedureType = 'EMERGENCY' ;



-- 13.Calculate the total cost spent by each pet owner on procedures

select concat(po.`Name`,' ', po.Surname) as Owners_name , sum(pd.Price) as Total_cost_on_procedures_by_owners 
from petowners po
LEFT JOIN pets p ON po.OwnerID= p.OwnerID
LEFT JOIN procedureshistory ph ON ph.PetID= p.PetID
LEFT JOIN proceduresdetails pd ON ph.ProcedureType=pd.ProcedureType AND ph.ProcedureSubCode=pd.ProcedureSubCode
Group by Owners_name
HAVING Total_cost_on_procedures_by_owners is not null ;
; 


-- 14.Count the number of pets of each kind. 

select p.Kind, count(p.`Name`) as number_of_pets
from pets p
group by p.Kind ;


-- 15.Group pets by their kind and gender and count the number of pets in each group. 


select p.Kind,p.Gender,count(p.`Name`) as pets_count
from pets p
group by p.Kind ,p.Gender ;

-- 16.Show the average age of pets for each kind, but only for kinds that have more than 5 pets. 

select p.Kind,p.Gender, count(p.`Name`) as count_of_pets, avg(p.Age) as average_age_of_pets
from pets p
group by p.Kind, p.Gender
having count_of_pets > 5; 

-- 17.Find the types of procedures that have an average cost greater than $50. 
select pd.ProcedureType ,avg(price) as average_price_of_procedures
from proceduresdetails pd
group by pd.ProcedureType 
having average_price_of_procedures > 50 ;


-- 18.Classify pets as 'Young', 'Adult', or 'Senior' based on their age. Age less then 3 Young, Age between 3and 8 Adult, else Senior. 

select  p.PetID, p.Age, case 
when p.Age <3 then "Young" 
when  p.Age>=3 AND p.Age<8 then "Adult" 
when p.Age>= 8 then "Senior"
end as pets_classification
from pets p ; 


-- 19. Calculate the total spending of each pet owner on procedures, labeling them  as 'Low Spender' for spending under $100, 'Moderate Spender' for spending 
-- between $100 and $500, and 'High Spender' for spending over $500. 

select 
				            Owners_name , Total_cost_on_procedures_by_owners, 
							case 
							when Total_cost_on_procedures_by_owners<100 then "Low Spender" 
							when Total_cost_on_procedures_by_owners>=100 and Total_cost_on_procedures_by_owners<500 then "Moderate Spender" 
							when Total_cost_on_procedures_by_owners>=500 then "High Spender" 
							end as classification_of_owner
            
from 
						( select concat(po.`Name`,' ', po.Surname) as Owners_name , sum(pd.Price) as Total_cost_on_procedures_by_owners
                          from petowners po
									LEFT JOIN pets p ON po.OwnerID= p.OwnerID
									LEFT JOIN procedureshistory ph ON ph.PetID= p.PetID
									LEFT JOIN proceduresdetails pd ON ph.ProcedureType=pd.ProcedureType AND ph.ProcedureSubCode=pd.ProcedureSubCode
									Group by Owners_name)
AS subquery 
WHERE Total_cost_on_procedures_by_owners is not null;
 
 
 
 -- 20.Show the gender of pets with a custom label ('Boy' for male, 'Girl' for female) 

select p.PetID, p.Gender, 
	
    case 
		when p.Gender= "male" then "Boy"
		when p.Gender= "female" then "Girl"
	end as classification_for_gender

from pets p ; 



-- 21. For each pet, display the pet's name, the number of procedures they've had, 
-- and a status label: 'Regular' for pets with 1 to 3 procedures, 'Frequent' for 4 to 
-- 7 procedures, and 'Super User' for more than 7 procedures. 


SELECT 	
			PetID, `Name`, Count_of_procedures, 
            case 	
				when Count_of_procedures >=1 and count_of_procedures<=3 then "Regular" 
                when Count_of_procedures >=4 and count_of_procedures<=7 then "Frequent"
                when Count_of_procedures >7 then "Super User"
			end as classification_of_user 

FROM 
			(select	
					p.PetID, p.`Name`, COUNT(ph.ProcedureType) as Count_of_procedures
			from 
					pets p 
			left join 
					procedureshistory ph ON p.PetID= ph.PetID
			group by 
					p.PetID, p.`Name` 
			) 

as subquery ;



-- 22. Rank pets by age within each kind. 


SELECT
		p.Kind, p.Age,
        RANK() OVER (PARTITION BY p.Kind ORDER BY p.Age Desc) AS pet_rank
FROM
    pets p;
    
    
-- 23.Assign a dense rank to pets based on their age, regardless of kind. 

SELECT
		p.Kind, p.Age,
        DENSE_RANK() OVER (ORDER BY p.Age Desc) AS pet_rank
FROM
    pets p;
    

-- 24. For each pet, show the name of the next and previous pet in alphabetical order. 

SELECT
    p.`Name`,
    LAG(p.`Name`) OVER (ORDER BY p.`Name`) AS previous_pet,
    LEAD(p.`Name`) OVER (ORDER BY p.`Name`) AS next_pet
FROM
    pets p; 
    
    
-- 25. Show the average age of pets, partitioned by their kind 
    
select p.Kind, avg(p.Age) as average_age
from pets p 
group by p.Kind ;


 -- 26.Create a CTE that lists all pets, then select pets older than 5 years from the CTE.
 
 -- Creating a CTE to list all pets

WITH AllPetsCTE AS (
    SELECT
        PetID, `Name`, Kind, Gender, Age
    FROM
        pets
)

SELECT
    PetID, `Name`, Kind, Gender, Age
FROM
    AllPetsCTE
WHERE
    Age > 5;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 












































































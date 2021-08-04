
                                                                        ## Subqueires:-
select * from employees;
select * from departments;

## SUBQUERY IN WHERE CLAUSE::-
-- Q1 -- select first_name,last_name whose department_name is accounting;
select first_name,last_name,department_name 
from employees e join departments d 
on e.department_id=d.department_id
where department_name = 'accounting';                                                                           ## JOINS APPROACH

select first_name,last_name from employees where
department_id=(select department_id from departments where department_name='accounting');                       ## SUBQUERY APPROACH 
## (subquery in where clause we can select only one column )
-- when are we only going to filter out the data from another table not display we can use subquery (uses less memeory)
-- when are we want to filter and also display the data from another table we use join;

-- Q2 -- display the names of the employees who work in the department where neena works;
select first_name,last_name from employees where
department_id=(select department_id from employees where first_name='neena');
																											   -- (like this subquery is called as independent subquery)
-- Q3 -- display the name of the employees working in accounts and finance departments;
select first_name,last_name from employees where
department_id in (select department_id from departments where department_name in ('accounts','finance'));     --- USING ##### IN 

-- Q4 to display the names of the employees whose salary is less than the salaries of all the people working in department 60.
select first_name,last_name,salary from employees where
salary < all (select salary from employees where department_id = 60);                                         --- USING #### ALL

-- Q5 to list the names of the employees working in seattle. 
select * from locations;
select * from employees;
select * from departments;

select first_name,last_name from employees where 
department_id in (select department_id from departments where location_id=(select location_id from locations where city='seattle'));      -- NESTED SUBQUEIERS::_

-- Q6 to display the names of the employees who work in same department as 'gerald' and have the same designation as him:
select first_name,last_name from employees where
department_id=(select department_id from employees where first_name='gerald') and
job_id=(select job_id from employees where first_name='gerald');                                                                         -- AND  

-- Q7 to display the names of the employees who work in the department of purchasing and work as clerk in it.
select first_name,last_name from employees where 
department_id=(select department_id from departments where department_name='purchasing') and
job_id = (select job_id from jobs where job_title like '%Purcha%clerk%')       

                                               -- correlated subquery:
-- Q1 to get the names of the employees who draw a salary that is **less than his department's** average salary.
select first_name,last_name from 
employees o where salary < (select avg(salary) from employees i where i.department_id=o.department_id);

-- Q2-- example for using a query in place of column name with the select statement:
select first_name,last_name,salary,(select avg(salary) from employees i
									where i.department_id=o.department_id) as dept_sal
                                    from employees o;
################################################################################################################################################################################

-- Q1 scenario:
-- A ecommerce site is planning for a campaign to convert its prospect customers to customers. hence, the team needs the list of such prospect customers
-- who have registered to the site but not placed an order. generate such list.
select * from customers;
select * from orders;
select customernumber,customername from customers where customernumber not in (select ordernumber from orders);
-- 2nd method using correlated subquery::
## ********************************************************************************************************
select * from customers o where not exists (select * from orders i where i.customernumber=o.customernumber);


                                                          -- ######## WINDOW FUNCTION ####### --

## Normal correlated subquery at select clause::::---
select first_name,last_name,salary,(select avg(salary) from employees i where i.employee_id=o.employee_id) as dept_sal from employees o;


                                                            -- #### AGGREGATE FUNCTIONS #### --
## using window function approach::-
select first_name,last_name,department_id,salary,
avg(salary) over (partition by department_id) as dept_sal
from employees;

##### to display the employee details and the maximum salary drawn in his department
select first_name,last_name,department_id,salary,
max(salary) over (partition by department_id) as max_sal_by_dept
from employees;

##### to display the employee details and the minimum salary drawn for his job designation::
select first_name,last_name,department_id,salary,job_id,
min(salary) over (partition by job_id) as job_min_sal
from employees;

#### to display the list of employees, his department names and the total employees working in his deapartment::
select first_name,last_name,department_name,
count(employee_id) over (partition by department_name) as no_of_employees
from employees e join departments d
on e.department_id=d.department_id;

 #### to display the list of employees, his department names and the total employees working in the company:
select first_name,department_name,
count(employee_id) over ()
from employees e join departments d       -- without mentionting the partition by it will (selects as a whole column as one)
on e.department_id=d.department_id;       -- dont do like this.

 ### scinario 
 -- the finance department is planning for the budget for the next quarter.
 -- the team would like to generate a report with the list of employees, their 
 -- departments, salary and the projected budget for the next quarter for his department.
 -- generate such report.
 select first_name,salary,department_id,
 sum(salary*3) over (partition by department_id) as qtr_budget,
 sum(salary*6) over (partition by department_id) as half_year_budget,
 sum(salary*12) over (partition by department_id) as year_budget
 from employees;
 
                                                           -- #### ANALYTICAL FUNCTIONS #### --
 
 -- ##### to rank the employees based on the salary drawn by them. the person with the highest salary to the ranked 1 so on: 
select *,
rank() over (order by salary desc)
from employees;                                              ## RANK

select *,
dense_rank() over (order by salary desc)
from employees;                                              ## DENSE RANK

select *,
row_number() over (order by salary desc)                     ## ROW NUMBER
from employees;    

select *,
percent_rank() over (order by salary desc)                   ## PERCENT RANK                
from employees;

 #### to rank the employees in the departments based on the salary drawn by them
 -- the person with highest salary in the department should be ranked 1 and so on.
select first_name,last_name,department_id,salary,
rank() over (partition by department_id order by salary desc)
from employees;                                                                        

 ## to display the list of employees and pair every employee with the 5th person in the department::
 select employee_id,first_name,last_name,department_id, 
 nth_value(first_name,5) over (partition by department_id)
 from employees;                                               ## Nth VALUE                      

 #### to display the customer numbers, order ids and the order dates along with the previous order date for every customer in the table::
select * from customers;
select * from orders;
select customernumber,ordernumber,orderdate,
lag(orderdate,1) over (partition by customernumber order by orderdate) as previous_orderdate
from orders;

#### to display the customer numbers, order ids and the order dates along with the previous order date and  the next order date for every customer in the table::
select customernumber,ordernumber,orderdate,
lag(orderdate) over (partition by customernumber order by orderdate)  as previous_order_date,
lead(orderdate) over (partition by customernumber order by orderdate) as nxt_order_date
from orders;

select *,
ntile(5) over (partition by department_id)
from employees;                                               ## Ntile:::-

 #### the ecommerce site is performing analysis on the life time customer value. and the team needs a report with the details about the customer names etc
 -- and the orders related details along with the date when the customer began his/her journey with the site. generate such a report::
 select * from customers;
 select * from orders;
 select * from  orderdetails;
 select c.customernumber,c.customername,o.ordernumber,o.orderdate,
 first_value(o.orderdate) over (partition by customernumber order by orderdate asc) as first_order_date
 from customers c join orders o 
 on c.customerNumber = o.customerNumber;                                                                         ## FIRST VALUE

 ## for the above question,also capture the most recent order date for the customer for every row;
select c.customernumber,c.customername,o.ordernumber,o.orderdate,
first_value(o.orderdate) over (partition by customernumber order by orderdate asc) as first_order_date,
last_value(o.orderdate) over (partition by c.customernumber order by o.orderdate rows between unbounded preceding and unbounded following) as last_order_date
from customers c join orders o 
on c.customerNumber = o.customerNumber;                                                                         ## LAST VALUE






















































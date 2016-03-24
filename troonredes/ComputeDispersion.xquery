(: Author: M. Marx
   Date: 2013-01-22
   :)

(: local:dispersion($data,$len) computes the dispersion of a list of datapoints $data in between 1 and $len.
This always returns a value between 0 and 1 (0 for empty $data, 1 when $data = [1,2,3,....,$len]

For our application in NameScape, $data is a list of paragraph-numbers in which a character occurs 
and $len is the total number of paragraphs in a book.
We thus calculate the dispersion for every NE.
:)

declare function local:dispersion($data as xs:integer*,$len as xs:integer){
if (not(empty($data[. lt 1 or . gt $len])))
    then "ERROR: non valid input"
    else
avg(local:dispersionHELP(distinct-values($data),$len))  (: accidental doubles in input data are removed :)
};

declare function local:dispersionHELP($data,$len){
 
let $avg := count($data) div $len
let $nlen := round($len div 2)
let $ndata := distinct-values(for $i in $data return round($i div 2))
return
($avg, if ($nlen eq 1) then () else local:dispersionHELP($ndata,$nlen))
};

(:  Test material :)

(: test data :)

declare variable $tests :=
<tt>
<t t='(1)'/>
<t t='(5)'/>
<t t='(7)'/>
<t t='(3,4)'/>
<t t='(3,6)'/>
<t t='(2,7)'/>
<t t='(1,2,3,4)'/>
<t t='(1,3,5,7)'/>
<t t='(1,2,3,4,5,6,7,8)'/>
</tt>
;


(: run the dispersion over the test-data :)
for $t in $tests//t/@t
    let $test := for $i in tokenize(replace($t,'\(|\)',''),',') return xs:integer($i)
    return
 (  '&#10;' ,local:dispersionHELP($test,8),  concat('&#09;',$t,'&#09;',string(local:dispersion($test,8)))) (: ,'&#10;')  :)

(:
(: output of query :)


0.125 0.25 0.5 	(1)	0.291666666666666667 
 0.125 0.25 0.5 	(5)	0.291666666666666667 
 0.125 0.25 0.5 	(7)	0.291666666666666667 
 0.25 0.25 0.5 	(3,4)	0.333333333333333333 
 0.25 0.5 1 	(3,6)	0.583333333333333333 
 0.25 0.5 1 	(2,7)	0.583333333333333333 
 0.5 0.5 0.5 	(1,2,3,4)	0.5 
 0.5 1 1 	(1,3,5,7)	0.833333333333333333 
 1 1 1 	(1,2,3,4,5,6,7,8)	1
 
 
 
 (1)	0.291666666666666667
 (5)	0.291666666666666667
 (7)	0.291666666666666667
 (3,4)	0.333333333333333333
 (3,6)	0.583333333333333333
 (2,7)	0.583333333333333333
 (1,2,3,4)	0.5
 (1,3,5,7)	0.833333333333333333
 (1,2,3,4,5,6,7,8)	1
 
 :)

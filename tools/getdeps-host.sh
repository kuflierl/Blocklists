regex='^domain(black|white)list (text|web)source [\w-]+(\/[\w-]+)*$'
while IFS="" read -r p || [ -n "$p" ]
do
  echo "$p" | grep -oPq "$regex" || continue
  p1=`echo $p | awk '{print $1;}'`
  p2=`echo $p | awk '{print $2;}'`
  p3=`echo $p | awk '{print $3;}'`
  out="./build/$p2/$p3.$p1.o"
  echo "$out"
done < $1

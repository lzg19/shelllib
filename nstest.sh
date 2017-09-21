#/bin/sh
NSNUM=$1

echo "begin to add namesapce $NSNUM"
for (( ns=1; ns<=$NSNUM; ns++ ))
do
	nsname=ns${ns}
	#echo "try to create network namespace $nsname"
	sudo ip netns add $nsname
	if [ $? != 0 ]
	then
		echo "create namespace $nsname error"
	else
		printf "."
	#	echo "create namespace $nsname successful"
	fi
done
echo ""
echo "begin to delete namespace $NSNUM"
for (( ns=1; ns<=$NSNUM; ns++ ))
do
	nsname=ns${ns}
	#echo "begin to delete namespace $nsname"
	sudo ip netns delete $nsname
	if [ $? != 0 ]
	then
		echo "delete namespace $nsname error"
	else
		printf "."
		#echo "delete namesacpe $nsname ok"
	fi
done
echo ""

VMOS=$1
set -e
#Making sure I have everything I need
for i in brew spark 
do
	command -v $i >/dev/null 2>&1 || { echo >&2 "I require $i but it's not installed.  Aborting."; exit 1; }
done
command -v spark >/dev/null 2>&1 || { echo >&2 "I require spark but it's not installed.  Going to install."; brew install spark; }

#Setting up a killGroup so that the process all close cleanly
trap killgroup SIGINT

killgroup(){
  echo killing...
  kill 0
}
if [ "$2" == " " ]
then
    echo "Setting the virtualization method is in beta and may not work"
    hypervisor=$2
else
    hypervisor="vmware"
fi
myPID=`ps aux | grep -i "$hypervisor" | grep -i "$VMOS" | awk '{print $2}'`
#echo $myPID
#exit
echo "Loading"
if [ "$3" != " " ]; then
	echo "Average Accuracy"
	while [ 1 ]; do top -l 10  -pid "$myPID" | grep "$hypervisor" | tail -n 9 | awk '{print $3}' 2> /dev/null| spark | tr -d '\n' ; done
else
	while [ 1 ]; do for i in {1..10}; do ps -p "$myPID" -o %cpu | grep [[:digit:]]; done | spark| tr  '\n' '\r' ; done
fi
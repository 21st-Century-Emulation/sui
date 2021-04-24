docker build -q -t sui .
docker run --rm --name sui -d -p 8080:8080 sui

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":128,"state":{"a":0,"b":1,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":0}}' \
  http://localhost:8080/api/v1/execute?operand1=1`
EXPECTED='{"id":"abcd", "opcode":128,"state":{"a":255,"b":1,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":true,"zero":false,"auxCarry":false,"parity":true,"carry":true},"programCounter":1,"stackPointer":2,"cycles":7}}'

docker kill sui

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mSUI Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mSUI Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi
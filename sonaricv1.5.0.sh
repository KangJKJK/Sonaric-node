#!/bin/bash

# 컬러 정의
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export NC='\033[0m'  # No Color

execute_and_prompt() {
    local message="$1"
    local command="$2"
    echo -e "${YELLOW}${message}${NC}"
    eval "$command"
    echo -e "${GREEN}Done.${NC}"
}

# 1. UFW 설치 및 포트 개방
execute_and_prompt "Installing UFW..." "sudo apt-get install -y ufw"
execute_and_prompt "Enabling UFW..." "sudo ufw enable"
execute_and_prompt "Allowing necessary ports through UFW..." \
    "sudo ufw allow 44003/tcp && \
     sudo ufw allow 44004/tcp && \
     sudo ufw allow 44005/tcp && \
     sudo ufw allow 44006/tcp"

# 2. Sonaric 설치 스크립트 실행
execute_and_prompt "Executing Sonaric installation script..." "./sonaric.sh"

# 사용자 안내 메시지
echo -e "${RED}설치 스크립트를 실행하면 다음과 같은 안내 메시지가 나옵니다:${NC}"

echo -e "${RED}1.Do you want to change your Sonaric node name? (y/N):${NC}"
echo -e "${YELLOW}y를 선택하고 노드 이름을 설정하세요.${NC}"

echo -e "${RED}2.Do you want to save your Sonaric identity? (y/N):${NC}"
echo -e "${YELLOW}y를 선택하고 비밀번호를 설정하세요.${NC}"

# 구동 확인
execute_and_prompt "Checking Sonaric node status..." "sonaric node-info"

echo -e "${YELLOW}모든작업이 완료되었습니다.컨트롤+A+D로 스크린을 종료해주세요${NC}"
echo -e "${GREEN}반드시 디스코드와 연동을해야합니다. 텔레그램을 확인하세요.${NC}"
# 스크립트 작성자: kangjk
#!/bin/bash

# 컬러 정의
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export NC='\033[0m'  # No Color

# 함수: 명령어 실행 및 결과 확인, 오류 발생 시 사용자에게 계속 진행할지 묻기
execute_with_prompt() {
    local message="$1"
    local command="$2"
    echo -e "${YELLOW}${message}${NC}"
    echo "Executing: $command"
    
    # 명령어 실행 및 오류 내용 캡처
    output=$(eval "$command" 2>&1)
    exit_code=$?

    # 출력 결과를 화면에 표시
    echo "$output"

    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}Error: Command failed: $command${NC}" >&2
        echo -e "${RED}Detailed Error Message:${NC}"
        echo "$output" | sed 's/^/  /'  # 상세 오류 메시지를 들여쓰기하여 출력
        echo
        
        # 사용자에게 계속 진행할지 묻기
        read -p "오류가 발생했습니다. 계속 진행하시겠습니까? (Y/N): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${RED}스크립트를 종료합니다.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Success: Command completed successfully.${NC}"
    fi
}

# 안내 메시지
echo -e "${YELLOW}설치 도중 문제가 발생하면 다음 명령어를 입력하고 다시 시도하세요:${NC}"
echo -e "${YELLOW}sudo rm -f /root/sonaricv1.5.0.sh${NC}"
echo

# 1. UFW 설치 및 포트 개방
execute_and_prompt "UFW를 설치합니다..." "sudo apt-get install -y ufw"
execute_and_prompt "UFW를 활성화합니다...반응이 없으면 엔터를 누르세요" "sudo ufw enable"
execute_and_prompt "UFW를 통해 필요한 포트를 개방합니다..." \
    "sudo ufw allow 44003/tcp && \
     sudo ufw allow 44004/tcp && \
     sudo ufw allow 44005/tcp && \
     sudo ufw allow 44006/tcp"

# 사용자 안내 메시지
echo -e "${RED}설치 스크립트를 실행하면 다음과 같은 안내 메시지가 나옵니다:${NC}"

echo -e "${RED}1. Sonaric 노드 이름을 변경하시겠습니까? (y/N):${NC}"
echo -e "${YELLOW}y를 선택하고 노드 이름을 설정하세요.${NC}"

echo -e "${RED}2. Sonaric ID를 저장하시겠습니까? (y/N):${NC}"
echo -e "${YELLOW}y를 선택하고 비밀번호를 설정하세요.${NC}"

# 2. Sonaric 설치 스크립트 실행
execute_with_prompt "Sonaric 설치 스크립트를 실행합니다..." "sh -c "$(curl -fsSL http://get.sonaric.xyz/scripts/install.sh"
echo "Sonaric 구성 설정 중 (사용자 입력 필요)..."
# `stdbuf`를 사용하여 명령어의 출력을 실시간으로 처리합니다.
stdbuf -i0 -o0 -e0 bash install.sh

# 3구동 확인
execute_with_prompt "Sonaric 노드 상태를 확인합니다..." "sonaric node-info"

echo -e "${YELLOW}모든 작업이 완료되었습니다. 컨트롤+A+D로 스크린을 종료해주세요.${NC}"
echo -e "${GREEN}반드시 디스코드와 연동을 해야 합니다. 텔레그램을 확인하세요.${NC}"
echo -e "${GREEN}스크립트 작성자:https://t.me/kjkresearch${NC}"

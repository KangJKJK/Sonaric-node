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
#!/bin/bash

# 최적화 스크립트

echo -e "${GREEN}시스템 최적화 작업을 시작합니다.${NC}"

# 불필요한 패키지 자동 제거
echo -e "${GREEN}불필요한 패키지 자동 제거 중...${NC}"
sudo apt autoremove -y

# .deb 파일 삭제
echo -e "${GREEN}.deb 파일 삭제 중...${NC}"
sudo rm /root/*.deb

# 패키지 캐시 정리
echo -e "${GREEN}패키지 캐시 정리 중...${NC}"
sudo apt-get clean

# /tmp 디렉토리 비우기
echo -e "${GREEN}/tmp 디렉토리 비우기 중...${NC}"
sudo rm -rf /tmp/*

# 사용자 캐시 비우기
echo -e "${GREEN}사용자 캐시 비우기 중...${NC}"
rm -rf ~/.cache/*

# .sh 및 .rz 파일 삭제
echo -e "${GREEN}.sh 및 .rz 파일 삭제 중...${NC}"
sudo rm -f /root/*.sh /root/*.rz

# Docker가 설치되어 있는지 확인
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}Docker가 설치되어 있습니다. Docker 관련 작업을 수행합니다.${NC}"

    # Docker 로그 정리 스크립트 작성
    echo -e "${GREEN}Docker 로그 정리 스크립트 작성 중...${NC}"
    echo -e '#!/bin/bash\ndocker ps -q | xargs -I {} docker logs --tail 0 {} > /dev/null' | sudo tee /usr/local/bin/docker-log-cleanup.sh
    sudo chmod +x /usr/local/bin/docker-log-cleanup.sh

    # Docker 로그 정리 작업을 크론에 추가
    echo -e "${GREEN}크론 작업 추가 중...${NC}"
    (crontab -l ; echo '0 0 * * * /usr/local/bin/docker-log-cleanup.sh') | sudo crontab -

    # 중지된 모든 컨테이너 제거
    echo -e "${GREEN}중지된 모든 컨테이너 제거 중...${NC}"
    sudo docker container prune -f

    # 사용하지 않는 모든 이미지 제거
    echo -e "${GREEN}사용하지 않는 모든 이미지 제거 중...${NC}"
    sudo docker image prune -a -f

    # 사용하지 않는 모든 볼륨 제거
    echo -e "${GREEN}사용하지 않는 모든 볼륨 제거 중...${NC}"
    sudo docker volume prune -f

    # 사용하지 않는 모든 데이터 정리
    echo -e "${GREEN}사용하지 않는 모든 데이터 정리 중...${NC}"
    sudo docker system prune -a -f
else
    echo -e "${RED}Docker가 설치되어 있지 않습니다. Docker 관련 작업을 생략합니다.${NC}"
fi

echo -e "${GREEN}시스템 최적화 작업이 완료되었습니다.${NC}"

# 1. UFW 설치 및 포트 개방
execute_and_prompt "UFW를 설치합니다..." "sudo apt-get install -y ufw"
execute_and_prompt "UFW를 활성화합니다...반응이 없으면 엔터를 누르세요" "sudo ufw enable"
execute_and_prompt "UFW를 통해 필요한 포트를 개방합니다..." \
    "sudo ufw allow 44003/tcp && \
     sudo ufw allow 44004/tcp && \
     sudo ufw allow 44005/tcp && \
     sudo ufw allow 44006/tcp"

# 사용자 안내 메시지
echo -e "${GREEN}설치 스크립트를 실행하면 다음과 같은 안내 메시지가 나옵니다:${NC}"

echo -e "${GREEN}1. Sonaric 노드 이름을 변경하시겠습니까? (y/N):${NC}"
echo -e "${YELLOW}y를 선택하고 노드 이름을 설정하세요.${NC}"

echo -e "${GREEN}2. Sonaric ID를 저장하시겠습니까? (y/N):${NC}"
echo -e "${YELLOW}y를 선택하고 비밀번호를 설정하세요.${NC}"

# 2. Sonaric 설치 스크립트 실행
execute_with_prompt "Sonaric 설치 스크립트를 실행합니다..." "curl -fsSL http://get.sonaric.xyz/scripts/install.sh | sh"

# 3. 구동 확인
execute_with_prompt "Sonaric 노드 상태를 확인합니다..." "sonaric node-info"

echo -e "${YELLOW}모든 작업이 완료되었습니다. 컨트롤+A+D로 스크린을 종료해주세요.${NC}"
echo -e "${GREEN}반드시 디스코드와 연동을 해야 합니다. 텔레그램을 확인하세요.${NC}"
echo -e "${GREEN}스크립트 작성자:https://t.me/kjkresearch${NC}"

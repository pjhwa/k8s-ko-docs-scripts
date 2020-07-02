# k8s-ko-docs-scripts

한글화 번역 작업을 위한 스크립트입니다.

## For maintaining translated documents

### findbrokenlinks.sh

한글로 번역된 문서 중에서 다음을 찾아줍니다.
- 이미 번역된 문서 대신 영문 문서를 가리키고 있는 부분을 찾아줍니다.
- website/static/_redirects 에 포함된 URL(이미 한글 번역이 되어있는 문서로의)이 있는 부분을 찾아줍니다.

website/ 디렉터리에서 스크립트를 수행하면, website 상위 디렉터리에 brokenlinks.txt, brokenlinks-rd.txt 파일이 생성됩니다.



_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
   d:	e9 c6 00 00 00       	jmp    d8 <grep+0xd8>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    buf[m] = '\0';
  18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1b:	05 40 0f 00 00       	add    $0xf40,%eax
  20:	c6 00 00             	movb   $0x0,(%eax)
    p = buf;
  23:	c7 45 f0 40 0f 00 00 	movl   $0xf40,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  2a:	eb 51                	jmp    7d <grep+0x7d>
      *q = 0;
  2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  2f:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  35:	89 44 24 04          	mov    %eax,0x4(%esp)
  39:	8b 45 08             	mov    0x8(%ebp),%eax
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	e8 bc 01 00 00       	call   200 <match>
  44:	85 c0                	test   %eax,%eax
  46:	74 2c                	je     74 <grep+0x74>
        *q = '\n';
  48:	8b 45 e8             	mov    -0x18(%ebp),%eax
  4b:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  51:	83 c0 01             	add    $0x1,%eax
  54:	89 c2                	mov    %eax,%edx
  56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  59:	29 c2                	sub    %eax,%edx
  5b:	89 d0                	mov    %edx,%eax
  5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  64:	89 44 24 04          	mov    %eax,0x4(%esp)
  68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6f:	e8 74 05 00 00       	call   5e8 <write>
      }
      p = q+1;
  74:	8b 45 e8             	mov    -0x18(%ebp),%eax
  77:	83 c0 01             	add    $0x1,%eax
  7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
    m += n;
    buf[m] = '\0';
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  7d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  84:	00 
  85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  88:	89 04 24             	mov    %eax,(%esp)
  8b:	e8 af 03 00 00       	call   43f <strchr>
  90:	89 45 e8             	mov    %eax,-0x18(%ebp)
  93:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  97:	75 93                	jne    2c <grep+0x2c>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  99:	81 7d f0 40 0f 00 00 	cmpl   $0xf40,-0x10(%ebp)
  a0:	75 07                	jne    a9 <grep+0xa9>
      m = 0;
  a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  ad:	7e 29                	jle    d8 <grep+0xd8>
      m -= p - buf;
  af:	ba 40 0f 00 00       	mov    $0xf40,%edx
  b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  b7:	29 c2                	sub    %eax,%edx
  b9:	89 d0                	mov    %edx,%eax
  bb:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  cc:	c7 04 24 40 0f 00 00 	movl   $0xf40,(%esp)
  d3:	e8 ab 04 00 00       	call   583 <memmove>
{
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
  d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  db:	ba ff 03 00 00       	mov    $0x3ff,%edx
  e0:	29 c2                	sub    %eax,%edx
  e2:	89 d0                	mov    %edx,%eax
  e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  e7:	81 c2 40 0f 00 00    	add    $0xf40,%edx
  ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  f8:	89 04 24             	mov    %eax,(%esp)
  fb:	e8 e0 04 00 00       	call   5e0 <read>
 100:	89 45 ec             	mov    %eax,-0x14(%ebp)
 103:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 107:	0f 8f 05 ff ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}
 10d:	c9                   	leave  
 10e:	c3                   	ret    

0000010f <main>:

int
main(int argc, char *argv[])
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	83 e4 f0             	and    $0xfffffff0,%esp
 115:	83 ec 20             	sub    $0x20,%esp
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 118:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 11c:	7f 19                	jg     137 <main+0x28>
    printf(2, "usage: grep pattern [file ...]\n");
 11e:	c7 44 24 04 d4 0b 00 	movl   $0xbd4,0x4(%esp)
 125:	00 
 126:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 12d:	e8 97 06 00 00       	call   7c9 <printf>
    exit();
 132:	e8 91 04 00 00       	call   5c8 <exit>
  }
  pattern = argv[1];
 137:	8b 45 0c             	mov    0xc(%ebp),%eax
 13a:	8b 40 04             	mov    0x4(%eax),%eax
 13d:	89 44 24 18          	mov    %eax,0x18(%esp)
  
  if(argc <= 2){
 141:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 145:	7f 19                	jg     160 <main+0x51>
    grep(pattern, 0);
 147:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 14e:	00 
 14f:	8b 44 24 18          	mov    0x18(%esp),%eax
 153:	89 04 24             	mov    %eax,(%esp)
 156:	e8 a5 fe ff ff       	call   0 <grep>
    exit();
 15b:	e8 68 04 00 00       	call   5c8 <exit>
  }

  for(i = 2; i < argc; i++){
 160:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 167:	00 
 168:	e9 81 00 00 00       	jmp    1ee <main+0xdf>
    if((fd = open(argv[i], 0)) < 0){
 16d:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 171:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 178:	8b 45 0c             	mov    0xc(%ebp),%eax
 17b:	01 d0                	add    %edx,%eax
 17d:	8b 00                	mov    (%eax),%eax
 17f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 186:	00 
 187:	89 04 24             	mov    %eax,(%esp)
 18a:	e8 79 04 00 00       	call   608 <open>
 18f:	89 44 24 14          	mov    %eax,0x14(%esp)
 193:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 198:	79 2f                	jns    1c9 <main+0xba>
      printf(1, "grep: cannot open %s\n", argv[i]);
 19a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 19e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a8:	01 d0                	add    %edx,%eax
 1aa:	8b 00                	mov    (%eax),%eax
 1ac:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b0:	c7 44 24 04 f4 0b 00 	movl   $0xbf4,0x4(%esp)
 1b7:	00 
 1b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bf:	e8 05 06 00 00       	call   7c9 <printf>
      exit();
 1c4:	e8 ff 03 00 00       	call   5c8 <exit>
    }
    grep(pattern, fd);
 1c9:	8b 44 24 14          	mov    0x14(%esp),%eax
 1cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d1:	8b 44 24 18          	mov    0x18(%esp),%eax
 1d5:	89 04 24             	mov    %eax,(%esp)
 1d8:	e8 23 fe ff ff       	call   0 <grep>
    close(fd);
 1dd:	8b 44 24 14          	mov    0x14(%esp),%eax
 1e1:	89 04 24             	mov    %eax,(%esp)
 1e4:	e8 07 04 00 00       	call   5f0 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 1e9:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1ee:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1f2:	3b 45 08             	cmp    0x8(%ebp),%eax
 1f5:	0f 8c 72 ff ff ff    	jl     16d <main+0x5e>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 1fb:	e8 c8 03 00 00       	call   5c8 <exit>

00000200 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 200:	55                   	push   %ebp
 201:	89 e5                	mov    %esp,%ebp
 203:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 206:	8b 45 08             	mov    0x8(%ebp),%eax
 209:	0f b6 00             	movzbl (%eax),%eax
 20c:	3c 5e                	cmp    $0x5e,%al
 20e:	75 17                	jne    227 <match+0x27>
    return matchhere(re+1, text);
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	8d 50 01             	lea    0x1(%eax),%edx
 216:	8b 45 0c             	mov    0xc(%ebp),%eax
 219:	89 44 24 04          	mov    %eax,0x4(%esp)
 21d:	89 14 24             	mov    %edx,(%esp)
 220:	e8 36 00 00 00       	call   25b <matchhere>
 225:	eb 32                	jmp    259 <match+0x59>
  do{  // must look at empty string
    if(matchhere(re, text))
 227:	8b 45 0c             	mov    0xc(%ebp),%eax
 22a:	89 44 24 04          	mov    %eax,0x4(%esp)
 22e:	8b 45 08             	mov    0x8(%ebp),%eax
 231:	89 04 24             	mov    %eax,(%esp)
 234:	e8 22 00 00 00       	call   25b <matchhere>
 239:	85 c0                	test   %eax,%eax
 23b:	74 07                	je     244 <match+0x44>
      return 1;
 23d:	b8 01 00 00 00       	mov    $0x1,%eax
 242:	eb 15                	jmp    259 <match+0x59>
  }while(*text++ != '\0');
 244:	8b 45 0c             	mov    0xc(%ebp),%eax
 247:	8d 50 01             	lea    0x1(%eax),%edx
 24a:	89 55 0c             	mov    %edx,0xc(%ebp)
 24d:	0f b6 00             	movzbl (%eax),%eax
 250:	84 c0                	test   %al,%al
 252:	75 d3                	jne    227 <match+0x27>
  return 0;
 254:	b8 00 00 00 00       	mov    $0x0,%eax
}
 259:	c9                   	leave  
 25a:	c3                   	ret    

0000025b <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	0f b6 00             	movzbl (%eax),%eax
 267:	84 c0                	test   %al,%al
 269:	75 0a                	jne    275 <matchhere+0x1a>
    return 1;
 26b:	b8 01 00 00 00       	mov    $0x1,%eax
 270:	e9 9b 00 00 00       	jmp    310 <matchhere+0xb5>
  if(re[1] == '*')
 275:	8b 45 08             	mov    0x8(%ebp),%eax
 278:	83 c0 01             	add    $0x1,%eax
 27b:	0f b6 00             	movzbl (%eax),%eax
 27e:	3c 2a                	cmp    $0x2a,%al
 280:	75 24                	jne    2a6 <matchhere+0x4b>
    return matchstar(re[0], re+2, text);
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	8d 48 02             	lea    0x2(%eax),%ecx
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	0f b6 00             	movzbl (%eax),%eax
 28e:	0f be c0             	movsbl %al,%eax
 291:	8b 55 0c             	mov    0xc(%ebp),%edx
 294:	89 54 24 08          	mov    %edx,0x8(%esp)
 298:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 29c:	89 04 24             	mov    %eax,(%esp)
 29f:	e8 6e 00 00 00       	call   312 <matchstar>
 2a4:	eb 6a                	jmp    310 <matchhere+0xb5>
  if(re[0] == '$' && re[1] == '\0')
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	0f b6 00             	movzbl (%eax),%eax
 2ac:	3c 24                	cmp    $0x24,%al
 2ae:	75 1d                	jne    2cd <matchhere+0x72>
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	83 c0 01             	add    $0x1,%eax
 2b6:	0f b6 00             	movzbl (%eax),%eax
 2b9:	84 c0                	test   %al,%al
 2bb:	75 10                	jne    2cd <matchhere+0x72>
    return *text == '\0';
 2bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c0:	0f b6 00             	movzbl (%eax),%eax
 2c3:	84 c0                	test   %al,%al
 2c5:	0f 94 c0             	sete   %al
 2c8:	0f b6 c0             	movzbl %al,%eax
 2cb:	eb 43                	jmp    310 <matchhere+0xb5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d0:	0f b6 00             	movzbl (%eax),%eax
 2d3:	84 c0                	test   %al,%al
 2d5:	74 34                	je     30b <matchhere+0xb0>
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
 2da:	0f b6 00             	movzbl (%eax),%eax
 2dd:	3c 2e                	cmp    $0x2e,%al
 2df:	74 10                	je     2f1 <matchhere+0x96>
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
 2e4:	0f b6 10             	movzbl (%eax),%edx
 2e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ea:	0f b6 00             	movzbl (%eax),%eax
 2ed:	38 c2                	cmp    %al,%dl
 2ef:	75 1a                	jne    30b <matchhere+0xb0>
    return matchhere(re+1, text+1);
 2f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f4:	8d 50 01             	lea    0x1(%eax),%edx
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	83 c0 01             	add    $0x1,%eax
 2fd:	89 54 24 04          	mov    %edx,0x4(%esp)
 301:	89 04 24             	mov    %eax,(%esp)
 304:	e8 52 ff ff ff       	call   25b <matchhere>
 309:	eb 05                	jmp    310 <matchhere+0xb5>
  return 0;
 30b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 310:	c9                   	leave  
 311:	c3                   	ret    

00000312 <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 312:	55                   	push   %ebp
 313:	89 e5                	mov    %esp,%ebp
 315:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 318:	8b 45 10             	mov    0x10(%ebp),%eax
 31b:	89 44 24 04          	mov    %eax,0x4(%esp)
 31f:	8b 45 0c             	mov    0xc(%ebp),%eax
 322:	89 04 24             	mov    %eax,(%esp)
 325:	e8 31 ff ff ff       	call   25b <matchhere>
 32a:	85 c0                	test   %eax,%eax
 32c:	74 07                	je     335 <matchstar+0x23>
      return 1;
 32e:	b8 01 00 00 00       	mov    $0x1,%eax
 333:	eb 29                	jmp    35e <matchstar+0x4c>
  }while(*text!='\0' && (*text++==c || c=='.'));
 335:	8b 45 10             	mov    0x10(%ebp),%eax
 338:	0f b6 00             	movzbl (%eax),%eax
 33b:	84 c0                	test   %al,%al
 33d:	74 1a                	je     359 <matchstar+0x47>
 33f:	8b 45 10             	mov    0x10(%ebp),%eax
 342:	8d 50 01             	lea    0x1(%eax),%edx
 345:	89 55 10             	mov    %edx,0x10(%ebp)
 348:	0f b6 00             	movzbl (%eax),%eax
 34b:	0f be c0             	movsbl %al,%eax
 34e:	3b 45 08             	cmp    0x8(%ebp),%eax
 351:	74 c5                	je     318 <matchstar+0x6>
 353:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 357:	74 bf                	je     318 <matchstar+0x6>
  return 0;
 359:	b8 00 00 00 00       	mov    $0x0,%eax
}
 35e:	c9                   	leave  
 35f:	c3                   	ret    

00000360 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 360:	55                   	push   %ebp
 361:	89 e5                	mov    %esp,%ebp
 363:	57                   	push   %edi
 364:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 365:	8b 4d 08             	mov    0x8(%ebp),%ecx
 368:	8b 55 10             	mov    0x10(%ebp),%edx
 36b:	8b 45 0c             	mov    0xc(%ebp),%eax
 36e:	89 cb                	mov    %ecx,%ebx
 370:	89 df                	mov    %ebx,%edi
 372:	89 d1                	mov    %edx,%ecx
 374:	fc                   	cld    
 375:	f3 aa                	rep stos %al,%es:(%edi)
 377:	89 ca                	mov    %ecx,%edx
 379:	89 fb                	mov    %edi,%ebx
 37b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 37e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 381:	5b                   	pop    %ebx
 382:	5f                   	pop    %edi
 383:	5d                   	pop    %ebp
 384:	c3                   	ret    

00000385 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 385:	55                   	push   %ebp
 386:	89 e5                	mov    %esp,%ebp
 388:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 38b:	8b 45 08             	mov    0x8(%ebp),%eax
 38e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 391:	90                   	nop
 392:	8b 45 08             	mov    0x8(%ebp),%eax
 395:	8d 50 01             	lea    0x1(%eax),%edx
 398:	89 55 08             	mov    %edx,0x8(%ebp)
 39b:	8b 55 0c             	mov    0xc(%ebp),%edx
 39e:	8d 4a 01             	lea    0x1(%edx),%ecx
 3a1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 3a4:	0f b6 12             	movzbl (%edx),%edx
 3a7:	88 10                	mov    %dl,(%eax)
 3a9:	0f b6 00             	movzbl (%eax),%eax
 3ac:	84 c0                	test   %al,%al
 3ae:	75 e2                	jne    392 <strcpy+0xd>
    ;
  return os;
 3b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b3:	c9                   	leave  
 3b4:	c3                   	ret    

000003b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3b5:	55                   	push   %ebp
 3b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3b8:	eb 08                	jmp    3c2 <strcmp+0xd>
    p++, q++;
 3ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	0f b6 00             	movzbl (%eax),%eax
 3c8:	84 c0                	test   %al,%al
 3ca:	74 10                	je     3dc <strcmp+0x27>
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	0f b6 10             	movzbl (%eax),%edx
 3d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d5:	0f b6 00             	movzbl (%eax),%eax
 3d8:	38 c2                	cmp    %al,%dl
 3da:	74 de                	je     3ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
 3df:	0f b6 00             	movzbl (%eax),%eax
 3e2:	0f b6 d0             	movzbl %al,%edx
 3e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	0f b6 c0             	movzbl %al,%eax
 3ee:	29 c2                	sub    %eax,%edx
 3f0:	89 d0                	mov    %edx,%eax
}
 3f2:	5d                   	pop    %ebp
 3f3:	c3                   	ret    

000003f4 <strlen>:

uint
strlen(char *s)
{
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 401:	eb 04                	jmp    407 <strlen+0x13>
 403:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 407:	8b 55 fc             	mov    -0x4(%ebp),%edx
 40a:	8b 45 08             	mov    0x8(%ebp),%eax
 40d:	01 d0                	add    %edx,%eax
 40f:	0f b6 00             	movzbl (%eax),%eax
 412:	84 c0                	test   %al,%al
 414:	75 ed                	jne    403 <strlen+0xf>
    ;
  return n;
 416:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 419:	c9                   	leave  
 41a:	c3                   	ret    

0000041b <memset>:

void*
memset(void *dst, int c, uint n)
{
 41b:	55                   	push   %ebp
 41c:	89 e5                	mov    %esp,%ebp
 41e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 421:	8b 45 10             	mov    0x10(%ebp),%eax
 424:	89 44 24 08          	mov    %eax,0x8(%esp)
 428:	8b 45 0c             	mov    0xc(%ebp),%eax
 42b:	89 44 24 04          	mov    %eax,0x4(%esp)
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	89 04 24             	mov    %eax,(%esp)
 435:	e8 26 ff ff ff       	call   360 <stosb>
  return dst;
 43a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 43d:	c9                   	leave  
 43e:	c3                   	ret    

0000043f <strchr>:

char*
strchr(const char *s, char c)
{
 43f:	55                   	push   %ebp
 440:	89 e5                	mov    %esp,%ebp
 442:	83 ec 04             	sub    $0x4,%esp
 445:	8b 45 0c             	mov    0xc(%ebp),%eax
 448:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 44b:	eb 14                	jmp    461 <strchr+0x22>
    if(*s == c)
 44d:	8b 45 08             	mov    0x8(%ebp),%eax
 450:	0f b6 00             	movzbl (%eax),%eax
 453:	3a 45 fc             	cmp    -0x4(%ebp),%al
 456:	75 05                	jne    45d <strchr+0x1e>
      return (char*)s;
 458:	8b 45 08             	mov    0x8(%ebp),%eax
 45b:	eb 13                	jmp    470 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 45d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 461:	8b 45 08             	mov    0x8(%ebp),%eax
 464:	0f b6 00             	movzbl (%eax),%eax
 467:	84 c0                	test   %al,%al
 469:	75 e2                	jne    44d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 46b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 470:	c9                   	leave  
 471:	c3                   	ret    

00000472 <gets>:

char*
gets(char *buf, int max)
{
 472:	55                   	push   %ebp
 473:	89 e5                	mov    %esp,%ebp
 475:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 478:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 47f:	eb 4c                	jmp    4cd <gets+0x5b>
    cc = read(0, &c, 1);
 481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 488:	00 
 489:	8d 45 ef             	lea    -0x11(%ebp),%eax
 48c:	89 44 24 04          	mov    %eax,0x4(%esp)
 490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 497:	e8 44 01 00 00       	call   5e0 <read>
 49c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 49f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4a3:	7f 02                	jg     4a7 <gets+0x35>
      break;
 4a5:	eb 31                	jmp    4d8 <gets+0x66>
    buf[i++] = c;
 4a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4aa:	8d 50 01             	lea    0x1(%eax),%edx
 4ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4b0:	89 c2                	mov    %eax,%edx
 4b2:	8b 45 08             	mov    0x8(%ebp),%eax
 4b5:	01 c2                	add    %eax,%edx
 4b7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4bb:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c1:	3c 0a                	cmp    $0xa,%al
 4c3:	74 13                	je     4d8 <gets+0x66>
 4c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c9:	3c 0d                	cmp    $0xd,%al
 4cb:	74 0b                	je     4d8 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d0:	83 c0 01             	add    $0x1,%eax
 4d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4d6:	7c a9                	jl     481 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	01 d0                	add    %edx,%eax
 4e0:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4e6:	c9                   	leave  
 4e7:	c3                   	ret    

000004e8 <stat>:

int
stat(char *n, struct stat *st)
{
 4e8:	55                   	push   %ebp
 4e9:	89 e5                	mov    %esp,%ebp
 4eb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4f5:	00 
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
 4f9:	89 04 24             	mov    %eax,(%esp)
 4fc:	e8 07 01 00 00       	call   608 <open>
 501:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 504:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 508:	79 07                	jns    511 <stat+0x29>
    return -1;
 50a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 50f:	eb 23                	jmp    534 <stat+0x4c>
  r = fstat(fd, st);
 511:	8b 45 0c             	mov    0xc(%ebp),%eax
 514:	89 44 24 04          	mov    %eax,0x4(%esp)
 518:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51b:	89 04 24             	mov    %eax,(%esp)
 51e:	e8 fd 00 00 00       	call   620 <fstat>
 523:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 526:	8b 45 f4             	mov    -0xc(%ebp),%eax
 529:	89 04 24             	mov    %eax,(%esp)
 52c:	e8 bf 00 00 00       	call   5f0 <close>
  return r;
 531:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 534:	c9                   	leave  
 535:	c3                   	ret    

00000536 <atoi>:

int
atoi(const char *s)
{
 536:	55                   	push   %ebp
 537:	89 e5                	mov    %esp,%ebp
 539:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 53c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 543:	eb 25                	jmp    56a <atoi+0x34>
    n = n*10 + *s++ - '0';
 545:	8b 55 fc             	mov    -0x4(%ebp),%edx
 548:	89 d0                	mov    %edx,%eax
 54a:	c1 e0 02             	shl    $0x2,%eax
 54d:	01 d0                	add    %edx,%eax
 54f:	01 c0                	add    %eax,%eax
 551:	89 c1                	mov    %eax,%ecx
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	8d 50 01             	lea    0x1(%eax),%edx
 559:	89 55 08             	mov    %edx,0x8(%ebp)
 55c:	0f b6 00             	movzbl (%eax),%eax
 55f:	0f be c0             	movsbl %al,%eax
 562:	01 c8                	add    %ecx,%eax
 564:	83 e8 30             	sub    $0x30,%eax
 567:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 56a:	8b 45 08             	mov    0x8(%ebp),%eax
 56d:	0f b6 00             	movzbl (%eax),%eax
 570:	3c 2f                	cmp    $0x2f,%al
 572:	7e 0a                	jle    57e <atoi+0x48>
 574:	8b 45 08             	mov    0x8(%ebp),%eax
 577:	0f b6 00             	movzbl (%eax),%eax
 57a:	3c 39                	cmp    $0x39,%al
 57c:	7e c7                	jle    545 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 57e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 581:	c9                   	leave  
 582:	c3                   	ret    

00000583 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 583:	55                   	push   %ebp
 584:	89 e5                	mov    %esp,%ebp
 586:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 589:	8b 45 08             	mov    0x8(%ebp),%eax
 58c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 58f:	8b 45 0c             	mov    0xc(%ebp),%eax
 592:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 595:	eb 17                	jmp    5ae <memmove+0x2b>
    *dst++ = *src++;
 597:	8b 45 fc             	mov    -0x4(%ebp),%eax
 59a:	8d 50 01             	lea    0x1(%eax),%edx
 59d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 5a0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5a3:	8d 4a 01             	lea    0x1(%edx),%ecx
 5a6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 5a9:	0f b6 12             	movzbl (%edx),%edx
 5ac:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5ae:	8b 45 10             	mov    0x10(%ebp),%eax
 5b1:	8d 50 ff             	lea    -0x1(%eax),%edx
 5b4:	89 55 10             	mov    %edx,0x10(%ebp)
 5b7:	85 c0                	test   %eax,%eax
 5b9:	7f dc                	jg     597 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5be:	c9                   	leave  
 5bf:	c3                   	ret    

000005c0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5c0:	b8 01 00 00 00       	mov    $0x1,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <exit>:
SYSCALL(exit)
 5c8:	b8 02 00 00 00       	mov    $0x2,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <wait>:
SYSCALL(wait)
 5d0:	b8 03 00 00 00       	mov    $0x3,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <pipe>:
SYSCALL(pipe)
 5d8:	b8 04 00 00 00       	mov    $0x4,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <read>:
SYSCALL(read)
 5e0:	b8 05 00 00 00       	mov    $0x5,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <write>:
SYSCALL(write)
 5e8:	b8 10 00 00 00       	mov    $0x10,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <close>:
SYSCALL(close)
 5f0:	b8 15 00 00 00       	mov    $0x15,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <kill>:
SYSCALL(kill)
 5f8:	b8 06 00 00 00       	mov    $0x6,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <exec>:
SYSCALL(exec)
 600:	b8 07 00 00 00       	mov    $0x7,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <open>:
SYSCALL(open)
 608:	b8 0f 00 00 00       	mov    $0xf,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <mknod>:
SYSCALL(mknod)
 610:	b8 11 00 00 00       	mov    $0x11,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <unlink>:
SYSCALL(unlink)
 618:	b8 12 00 00 00       	mov    $0x12,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <fstat>:
SYSCALL(fstat)
 620:	b8 08 00 00 00       	mov    $0x8,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <link>:
SYSCALL(link)
 628:	b8 13 00 00 00       	mov    $0x13,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <mkdir>:
SYSCALL(mkdir)
 630:	b8 14 00 00 00       	mov    $0x14,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <chdir>:
SYSCALL(chdir)
 638:	b8 09 00 00 00       	mov    $0x9,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <dup>:
SYSCALL(dup)
 640:	b8 0a 00 00 00       	mov    $0xa,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <getpid>:
SYSCALL(getpid)
 648:	b8 0b 00 00 00       	mov    $0xb,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <sbrk>:
SYSCALL(sbrk)
 650:	b8 0c 00 00 00       	mov    $0xc,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <sleep>:
SYSCALL(sleep)
 658:	b8 0d 00 00 00       	mov    $0xd,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <uptime>:
SYSCALL(uptime)
 660:	b8 0e 00 00 00       	mov    $0xe,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <gettime>:
SYSCALL(gettime)
 668:	b8 16 00 00 00       	mov    $0x16,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <settickets>:
SYSCALL(settickets)
 670:	b8 17 00 00 00       	mov    $0x17,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 678:	55                   	push   %ebp
 679:	89 e5                	mov    %esp,%ebp
 67b:	83 ec 18             	sub    $0x18,%esp
 67e:	8b 45 0c             	mov    0xc(%ebp),%eax
 681:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 684:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 68b:	00 
 68c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68f:	89 44 24 04          	mov    %eax,0x4(%esp)
 693:	8b 45 08             	mov    0x8(%ebp),%eax
 696:	89 04 24             	mov    %eax,(%esp)
 699:	e8 4a ff ff ff       	call   5e8 <write>
}
 69e:	c9                   	leave  
 69f:	c3                   	ret    

000006a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a0:	55                   	push   %ebp
 6a1:	89 e5                	mov    %esp,%ebp
 6a3:	56                   	push   %esi
 6a4:	53                   	push   %ebx
 6a5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6af:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6b3:	74 17                	je     6cc <printint+0x2c>
 6b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b9:	79 11                	jns    6cc <printint+0x2c>
    neg = 1;
 6bb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c5:	f7 d8                	neg    %eax
 6c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6ca:	eb 06                	jmp    6d2 <printint+0x32>
  } else {
    x = xx;
 6cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6dc:	8d 41 01             	lea    0x1(%ecx),%eax
 6df:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6e8:	ba 00 00 00 00       	mov    $0x0,%edx
 6ed:	f7 f3                	div    %ebx
 6ef:	89 d0                	mov    %edx,%eax
 6f1:	0f b6 80 f8 0e 00 00 	movzbl 0xef8(%eax),%eax
 6f8:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6fc:	8b 75 10             	mov    0x10(%ebp),%esi
 6ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
 702:	ba 00 00 00 00       	mov    $0x0,%edx
 707:	f7 f6                	div    %esi
 709:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 710:	75 c7                	jne    6d9 <printint+0x39>
  if(neg)
 712:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 716:	74 10                	je     728 <printint+0x88>
    buf[i++] = '-';
 718:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71b:	8d 50 01             	lea    0x1(%eax),%edx
 71e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 721:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 726:	eb 1f                	jmp    747 <printint+0xa7>
 728:	eb 1d                	jmp    747 <printint+0xa7>
    putc(fd, buf[i]);
 72a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 72d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 730:	01 d0                	add    %edx,%eax
 732:	0f b6 00             	movzbl (%eax),%eax
 735:	0f be c0             	movsbl %al,%eax
 738:	89 44 24 04          	mov    %eax,0x4(%esp)
 73c:	8b 45 08             	mov    0x8(%ebp),%eax
 73f:	89 04 24             	mov    %eax,(%esp)
 742:	e8 31 ff ff ff       	call   678 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 747:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 74b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 74f:	79 d9                	jns    72a <printint+0x8a>
    putc(fd, buf[i]);
}
 751:	83 c4 30             	add    $0x30,%esp
 754:	5b                   	pop    %ebx
 755:	5e                   	pop    %esi
 756:	5d                   	pop    %ebp
 757:	c3                   	ret    

00000758 <printlong>:

static void
printlong(int fd, unsigned long long xx, int base, int sgn)
{
 758:	55                   	push   %ebp
 759:	89 e5                	mov    %esp,%ebp
 75b:	83 ec 38             	sub    $0x38,%esp
 75e:	8b 45 0c             	mov    0xc(%ebp),%eax
 761:	89 45 e0             	mov    %eax,-0x20(%ebp)
 764:	8b 45 10             	mov    0x10(%ebp),%eax
 767:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // Force hexadecimal
    uint upper, lower;
    upper = xx >> 32;
 76a:	8b 45 e0             	mov    -0x20(%ebp),%eax
 76d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 770:	89 d0                	mov    %edx,%eax
 772:	31 d2                	xor    %edx,%edx
 774:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lower = xx & 0xffffffff;
 777:	8b 45 e0             	mov    -0x20(%ebp),%eax
 77a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(upper) printint(fd, upper, 16, 0);
 77d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 781:	74 22                	je     7a5 <printlong+0x4d>
 783:	8b 45 f4             	mov    -0xc(%ebp),%eax
 786:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 78d:	00 
 78e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 795:	00 
 796:	89 44 24 04          	mov    %eax,0x4(%esp)
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	89 04 24             	mov    %eax,(%esp)
 7a0:	e8 fb fe ff ff       	call   6a0 <printint>
    printint(fd, lower, 16, 0);
 7a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7af:	00 
 7b0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7b7:	00 
 7b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 7bc:	8b 45 08             	mov    0x8(%ebp),%eax
 7bf:	89 04 24             	mov    %eax,(%esp)
 7c2:	e8 d9 fe ff ff       	call   6a0 <printint>
}
 7c7:	c9                   	leave  
 7c8:	c3                   	ret    

000007c9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
// bdg 10/05/2015: Add %l
void
printf(int fd, char *fmt, ...)
{
 7c9:	55                   	push   %ebp
 7ca:	89 e5                	mov    %esp,%ebp
 7cc:	83 ec 48             	sub    $0x48,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7cf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7d6:	8d 45 0c             	lea    0xc(%ebp),%eax
 7d9:	83 c0 04             	add    $0x4,%eax
 7dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7e6:	e9 ba 01 00 00       	jmp    9a5 <printf+0x1dc>
    c = fmt[i] & 0xff;
 7eb:	8b 55 0c             	mov    0xc(%ebp),%edx
 7ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f1:	01 d0                	add    %edx,%eax
 7f3:	0f b6 00             	movzbl (%eax),%eax
 7f6:	0f be c0             	movsbl %al,%eax
 7f9:	25 ff 00 00 00       	and    $0xff,%eax
 7fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 801:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 805:	75 2c                	jne    833 <printf+0x6a>
      if(c == '%'){
 807:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 80b:	75 0c                	jne    819 <printf+0x50>
        state = '%';
 80d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 814:	e9 88 01 00 00       	jmp    9a1 <printf+0x1d8>
      } else {
        putc(fd, c);
 819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 81c:	0f be c0             	movsbl %al,%eax
 81f:	89 44 24 04          	mov    %eax,0x4(%esp)
 823:	8b 45 08             	mov    0x8(%ebp),%eax
 826:	89 04 24             	mov    %eax,(%esp)
 829:	e8 4a fe ff ff       	call   678 <putc>
 82e:	e9 6e 01 00 00       	jmp    9a1 <printf+0x1d8>
      }
    } else if(state == '%'){
 833:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 837:	0f 85 64 01 00 00    	jne    9a1 <printf+0x1d8>
      if(c == 'd'){
 83d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 841:	75 2d                	jne    870 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 843:	8b 45 e8             	mov    -0x18(%ebp),%eax
 846:	8b 00                	mov    (%eax),%eax
 848:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 84f:	00 
 850:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 857:	00 
 858:	89 44 24 04          	mov    %eax,0x4(%esp)
 85c:	8b 45 08             	mov    0x8(%ebp),%eax
 85f:	89 04 24             	mov    %eax,(%esp)
 862:	e8 39 fe ff ff       	call   6a0 <printint>
        ap++;
 867:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 86b:	e9 2a 01 00 00       	jmp    99a <printf+0x1d1>
      } else if(c == 'l') {
 870:	83 7d e4 6c          	cmpl   $0x6c,-0x1c(%ebp)
 874:	75 38                	jne    8ae <printf+0xe5>
        printlong(fd, *(unsigned long long *)ap, 10, 0);
 876:	8b 45 e8             	mov    -0x18(%ebp),%eax
 879:	8b 50 04             	mov    0x4(%eax),%edx
 87c:	8b 00                	mov    (%eax),%eax
 87e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
 885:	00 
 886:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
 88d:	00 
 88e:	89 44 24 04          	mov    %eax,0x4(%esp)
 892:	89 54 24 08          	mov    %edx,0x8(%esp)
 896:	8b 45 08             	mov    0x8(%ebp),%eax
 899:	89 04 24             	mov    %eax,(%esp)
 89c:	e8 b7 fe ff ff       	call   758 <printlong>
        // long longs take up 2 argument slots
        ap++;
 8a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        ap++;
 8a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8a9:	e9 ec 00 00 00       	jmp    99a <printf+0x1d1>
      } else if(c == 'x' || c == 'p'){
 8ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8b2:	74 06                	je     8ba <printf+0xf1>
 8b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8b8:	75 2d                	jne    8e7 <printf+0x11e>
        printint(fd, *ap, 16, 0);
 8ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8bd:	8b 00                	mov    (%eax),%eax
 8bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 8c6:	00 
 8c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 8ce:	00 
 8cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d3:	8b 45 08             	mov    0x8(%ebp),%eax
 8d6:	89 04 24             	mov    %eax,(%esp)
 8d9:	e8 c2 fd ff ff       	call   6a0 <printint>
        ap++;
 8de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8e2:	e9 b3 00 00 00       	jmp    99a <printf+0x1d1>
      } else if(c == 's'){
 8e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8eb:	75 45                	jne    932 <printf+0x169>
        s = (char*)*ap;
 8ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8f0:	8b 00                	mov    (%eax),%eax
 8f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8fd:	75 09                	jne    908 <printf+0x13f>
          s = "(null)";
 8ff:	c7 45 f4 0a 0c 00 00 	movl   $0xc0a,-0xc(%ebp)
        while(*s != 0){
 906:	eb 1e                	jmp    926 <printf+0x15d>
 908:	eb 1c                	jmp    926 <printf+0x15d>
          putc(fd, *s);
 90a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90d:	0f b6 00             	movzbl (%eax),%eax
 910:	0f be c0             	movsbl %al,%eax
 913:	89 44 24 04          	mov    %eax,0x4(%esp)
 917:	8b 45 08             	mov    0x8(%ebp),%eax
 91a:	89 04 24             	mov    %eax,(%esp)
 91d:	e8 56 fd ff ff       	call   678 <putc>
          s++;
 922:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	0f b6 00             	movzbl (%eax),%eax
 92c:	84 c0                	test   %al,%al
 92e:	75 da                	jne    90a <printf+0x141>
 930:	eb 68                	jmp    99a <printf+0x1d1>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 932:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 936:	75 1d                	jne    955 <printf+0x18c>
        putc(fd, *ap);
 938:	8b 45 e8             	mov    -0x18(%ebp),%eax
 93b:	8b 00                	mov    (%eax),%eax
 93d:	0f be c0             	movsbl %al,%eax
 940:	89 44 24 04          	mov    %eax,0x4(%esp)
 944:	8b 45 08             	mov    0x8(%ebp),%eax
 947:	89 04 24             	mov    %eax,(%esp)
 94a:	e8 29 fd ff ff       	call   678 <putc>
        ap++;
 94f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 953:	eb 45                	jmp    99a <printf+0x1d1>
      } else if(c == '%'){
 955:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 959:	75 17                	jne    972 <printf+0x1a9>
        putc(fd, c);
 95b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 95e:	0f be c0             	movsbl %al,%eax
 961:	89 44 24 04          	mov    %eax,0x4(%esp)
 965:	8b 45 08             	mov    0x8(%ebp),%eax
 968:	89 04 24             	mov    %eax,(%esp)
 96b:	e8 08 fd ff ff       	call   678 <putc>
 970:	eb 28                	jmp    99a <printf+0x1d1>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 972:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 979:	00 
 97a:	8b 45 08             	mov    0x8(%ebp),%eax
 97d:	89 04 24             	mov    %eax,(%esp)
 980:	e8 f3 fc ff ff       	call   678 <putc>
        putc(fd, c);
 985:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 988:	0f be c0             	movsbl %al,%eax
 98b:	89 44 24 04          	mov    %eax,0x4(%esp)
 98f:	8b 45 08             	mov    0x8(%ebp),%eax
 992:	89 04 24             	mov    %eax,(%esp)
 995:	e8 de fc ff ff       	call   678 <putc>
      }
      state = 0;
 99a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 9a1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9a5:	8b 55 0c             	mov    0xc(%ebp),%edx
 9a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ab:	01 d0                	add    %edx,%eax
 9ad:	0f b6 00             	movzbl (%eax),%eax
 9b0:	84 c0                	test   %al,%al
 9b2:	0f 85 33 fe ff ff    	jne    7eb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 9b8:	c9                   	leave  
 9b9:	c3                   	ret    

000009ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9ba:	55                   	push   %ebp
 9bb:	89 e5                	mov    %esp,%ebp
 9bd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9c0:	8b 45 08             	mov    0x8(%ebp),%eax
 9c3:	83 e8 08             	sub    $0x8,%eax
 9c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c9:	a1 28 0f 00 00       	mov    0xf28,%eax
 9ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9d1:	eb 24                	jmp    9f7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d6:	8b 00                	mov    (%eax),%eax
 9d8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9db:	77 12                	ja     9ef <free+0x35>
 9dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9e3:	77 24                	ja     a09 <free+0x4f>
 9e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e8:	8b 00                	mov    (%eax),%eax
 9ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9ed:	77 1a                	ja     a09 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f2:	8b 00                	mov    (%eax),%eax
 9f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9fd:	76 d4                	jbe    9d3 <free+0x19>
 9ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a02:	8b 00                	mov    (%eax),%eax
 a04:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a07:	76 ca                	jbe    9d3 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0c:	8b 40 04             	mov    0x4(%eax),%eax
 a0f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a16:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a19:	01 c2                	add    %eax,%edx
 a1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1e:	8b 00                	mov    (%eax),%eax
 a20:	39 c2                	cmp    %eax,%edx
 a22:	75 24                	jne    a48 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a24:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a27:	8b 50 04             	mov    0x4(%eax),%edx
 a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2d:	8b 00                	mov    (%eax),%eax
 a2f:	8b 40 04             	mov    0x4(%eax),%eax
 a32:	01 c2                	add    %eax,%edx
 a34:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a37:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3d:	8b 00                	mov    (%eax),%eax
 a3f:	8b 10                	mov    (%eax),%edx
 a41:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a44:	89 10                	mov    %edx,(%eax)
 a46:	eb 0a                	jmp    a52 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a48:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4b:	8b 10                	mov    (%eax),%edx
 a4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a50:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a52:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a55:	8b 40 04             	mov    0x4(%eax),%eax
 a58:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a62:	01 d0                	add    %edx,%eax
 a64:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a67:	75 20                	jne    a89 <free+0xcf>
    p->s.size += bp->s.size;
 a69:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a6c:	8b 50 04             	mov    0x4(%eax),%edx
 a6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a72:	8b 40 04             	mov    0x4(%eax),%eax
 a75:	01 c2                	add    %eax,%edx
 a77:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a7a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a80:	8b 10                	mov    (%eax),%edx
 a82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a85:	89 10                	mov    %edx,(%eax)
 a87:	eb 08                	jmp    a91 <free+0xd7>
  } else
    p->s.ptr = bp;
 a89:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a8c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a8f:	89 10                	mov    %edx,(%eax)
  freep = p;
 a91:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a94:	a3 28 0f 00 00       	mov    %eax,0xf28
}
 a99:	c9                   	leave  
 a9a:	c3                   	ret    

00000a9b <morecore>:

static Header*
morecore(uint nu)
{
 a9b:	55                   	push   %ebp
 a9c:	89 e5                	mov    %esp,%ebp
 a9e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 aa1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 aa8:	77 07                	ja     ab1 <morecore+0x16>
    nu = 4096;
 aaa:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 ab1:	8b 45 08             	mov    0x8(%ebp),%eax
 ab4:	c1 e0 03             	shl    $0x3,%eax
 ab7:	89 04 24             	mov    %eax,(%esp)
 aba:	e8 91 fb ff ff       	call   650 <sbrk>
 abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 ac2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ac6:	75 07                	jne    acf <morecore+0x34>
    return 0;
 ac8:	b8 00 00 00 00       	mov    $0x0,%eax
 acd:	eb 22                	jmp    af1 <morecore+0x56>
  hp = (Header*)p;
 acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad8:	8b 55 08             	mov    0x8(%ebp),%edx
 adb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae1:	83 c0 08             	add    $0x8,%eax
 ae4:	89 04 24             	mov    %eax,(%esp)
 ae7:	e8 ce fe ff ff       	call   9ba <free>
  return freep;
 aec:	a1 28 0f 00 00       	mov    0xf28,%eax
}
 af1:	c9                   	leave  
 af2:	c3                   	ret    

00000af3 <malloc>:

void*
malloc(uint nbytes)
{
 af3:	55                   	push   %ebp
 af4:	89 e5                	mov    %esp,%ebp
 af6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 af9:	8b 45 08             	mov    0x8(%ebp),%eax
 afc:	83 c0 07             	add    $0x7,%eax
 aff:	c1 e8 03             	shr    $0x3,%eax
 b02:	83 c0 01             	add    $0x1,%eax
 b05:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b08:	a1 28 0f 00 00       	mov    0xf28,%eax
 b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b14:	75 23                	jne    b39 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b16:	c7 45 f0 20 0f 00 00 	movl   $0xf20,-0x10(%ebp)
 b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b20:	a3 28 0f 00 00       	mov    %eax,0xf28
 b25:	a1 28 0f 00 00       	mov    0xf28,%eax
 b2a:	a3 20 0f 00 00       	mov    %eax,0xf20
    base.s.size = 0;
 b2f:	c7 05 24 0f 00 00 00 	movl   $0x0,0xf24
 b36:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b3c:	8b 00                	mov    (%eax),%eax
 b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b44:	8b 40 04             	mov    0x4(%eax),%eax
 b47:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b4a:	72 4d                	jb     b99 <malloc+0xa6>
      if(p->s.size == nunits)
 b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4f:	8b 40 04             	mov    0x4(%eax),%eax
 b52:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b55:	75 0c                	jne    b63 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5a:	8b 10                	mov    (%eax),%edx
 b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b5f:	89 10                	mov    %edx,(%eax)
 b61:	eb 26                	jmp    b89 <malloc+0x96>
      else {
        p->s.size -= nunits;
 b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b66:	8b 40 04             	mov    0x4(%eax),%eax
 b69:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b6c:	89 c2                	mov    %eax,%edx
 b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b71:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b77:	8b 40 04             	mov    0x4(%eax),%eax
 b7a:	c1 e0 03             	shl    $0x3,%eax
 b7d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b83:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b86:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b8c:	a3 28 0f 00 00       	mov    %eax,0xf28
      return (void*)(p + 1);
 b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b94:	83 c0 08             	add    $0x8,%eax
 b97:	eb 38                	jmp    bd1 <malloc+0xde>
    }
    if(p == freep)
 b99:	a1 28 0f 00 00       	mov    0xf28,%eax
 b9e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ba1:	75 1b                	jne    bbe <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ba6:	89 04 24             	mov    %eax,(%esp)
 ba9:	e8 ed fe ff ff       	call   a9b <morecore>
 bae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 bb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bb5:	75 07                	jne    bbe <malloc+0xcb>
        return 0;
 bb7:	b8 00 00 00 00       	mov    $0x0,%eax
 bbc:	eb 13                	jmp    bd1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc7:	8b 00                	mov    (%eax),%eax
 bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 bcc:	e9 70 ff ff ff       	jmp    b41 <malloc+0x4e>
}
 bd1:	c9                   	leave  
 bd2:	c3                   	ret    

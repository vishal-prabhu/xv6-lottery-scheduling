
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 40 d0 10 80       	mov    $0x8010d040,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 b8 38 10 80       	mov    $0x801038b8,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 d0 88 10 	movl   $0x801088d0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
80100049:	e8 dc 4f 00 00       	call   8010502a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 50 0f 11 80 44 	movl   $0x80110f44,0x80110f50
80100055:	0f 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 54 0f 11 80 44 	movl   $0x80110f44,0x80110f54
8010005f:	0f 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 74 d0 10 80 	movl   $0x8010d074,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 54 0f 11 80    	mov    0x80110f54,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 44 0f 11 80 	movl   $0x80110f44,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 54 0f 11 80       	mov    0x80110f54,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 54 0f 11 80       	mov    %eax,0x80110f54

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 44 0f 11 80 	cmpl   $0x80110f44,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
801000bd:	e8 89 4f 00 00       	call   8010504b <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 54 0f 11 80       	mov    0x80110f54,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
80100104:	e8 a4 4f 00 00       	call   801050ad <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 40 d0 10 	movl   $0x8010d040,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 53 4c 00 00       	call   80104d77 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 44 0f 11 80 	cmpl   $0x80110f44,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 50 0f 11 80       	mov    0x80110f50,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
8010017c:	e8 2c 4f 00 00       	call   801050ad <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 44 0f 11 80 	cmpl   $0x80110f44,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 d7 88 10 80 	movl   $0x801088d7,(%esp)
8010019f:	e8 33 04 00 00       	call   801005d7 <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 1c 27 00 00       	call   801028f4 <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 e8 88 10 80 	movl   $0x801088e8,(%esp)
801001f6:	e8 dc 03 00 00       	call   801005d7 <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 df 26 00 00       	call   801028f4 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 ef 88 10 80 	movl   $0x801088ef,(%esp)
80100230:	e8 a2 03 00 00       	call   801005d7 <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
8010023c:	e8 0a 4e 00 00       	call   8010504b <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 54 0f 11 80    	mov    0x80110f54,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 44 0f 11 80 	movl   $0x80110f44,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 54 0f 11 80       	mov    0x80110f54,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 54 0f 11 80       	mov    %eax,0x80110f54

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 ae 4b 00 00       	call   80104e50 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 40 d0 10 80 	movl   $0x8010d040,(%esp)
801002a9:	e8 ff 4d 00 00       	call   801050ad <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 79 04 00 00       	call   80100808 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <printlong>:

static void
printlong(unsigned long long xx, int base, int sgn)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
801003a6:	8b 45 08             	mov    0x8(%ebp),%eax
801003a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801003af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // Force hexadecimal
    uint upper, lower;
    upper = xx >> 32;
801003b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801003b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801003b8:	89 d0                	mov    %edx,%eax
801003ba:	31 d2                	xor    %edx,%edx
801003bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lower = xx & 0xffffffff;
801003bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801003c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(upper) printint(upper, 16, 0);
801003c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003c9:	74 1b                	je     801003e6 <printlong+0x46>
801003cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801003d5:	00 
801003d6:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801003dd:	00 
801003de:	89 04 24             	mov    %eax,(%esp)
801003e1:	e8 0b ff ff ff       	call   801002f1 <printint>
    printint(lower, 16, 0);
801003e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801003f0:	00 
801003f1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801003f8:	00 
801003f9:	89 04 24             	mov    %eax,(%esp)
801003fc:	e8 f0 fe ff ff       	call   801002f1 <printint>
}
80100401:	c9                   	leave  
80100402:	c3                   	ret    

80100403 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100403:	55                   	push   %ebp
80100404:	89 e5                	mov    %esp,%ebp
80100406:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100409:	a1 14 b6 10 80       	mov    0x8010b614,%eax
8010040e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100411:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100415:	74 0c                	je     80100423 <cprintf+0x20>
    acquire(&cons.lock);
80100417:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
8010041e:	e8 28 4c 00 00       	call   8010504b <acquire>

  if (fmt == 0)
80100423:	8b 45 08             	mov    0x8(%ebp),%eax
80100426:	85 c0                	test   %eax,%eax
80100428:	75 0c                	jne    80100436 <cprintf+0x33>
    panic("null fmt");
8010042a:	c7 04 24 f6 88 10 80 	movl   $0x801088f6,(%esp)
80100431:	e8 a1 01 00 00       	call   801005d7 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100436:	8d 45 0c             	lea    0xc(%ebp),%eax
80100439:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100443:	e9 5b 01 00 00       	jmp    801005a3 <cprintf+0x1a0>
    if(c != '%'){
80100448:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044c:	74 10                	je     8010045e <cprintf+0x5b>
      consputc(c);
8010044e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100451:	89 04 24             	mov    %eax,(%esp)
80100454:	e8 af 03 00 00       	call   80100808 <consputc>
      continue;
80100459:	e9 41 01 00 00       	jmp    8010059f <cprintf+0x19c>
    }
    c = fmt[++i] & 0xff;
8010045e:	8b 55 08             	mov    0x8(%ebp),%edx
80100461:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100468:	01 d0                	add    %edx,%eax
8010046a:	0f b6 00             	movzbl (%eax),%eax
8010046d:	0f be c0             	movsbl %al,%eax
80100470:	25 ff 00 00 00       	and    $0xff,%eax
80100475:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100478:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010047c:	75 05                	jne    80100483 <cprintf+0x80>
      break;
8010047e:	e9 40 01 00 00       	jmp    801005c3 <cprintf+0x1c0>
    switch(c){
80100483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100486:	83 f8 6c             	cmp    $0x6c,%eax
80100489:	74 58                	je     801004e3 <cprintf+0xe0>
8010048b:	83 f8 6c             	cmp    $0x6c,%eax
8010048e:	7f 13                	jg     801004a3 <cprintf+0xa0>
80100490:	83 f8 25             	cmp    $0x25,%eax
80100493:	0f 84 e0 00 00 00    	je     80100579 <cprintf+0x176>
80100499:	83 f8 64             	cmp    $0x64,%eax
8010049c:	74 1d                	je     801004bb <cprintf+0xb8>
8010049e:	e9 e4 00 00 00       	jmp    80100587 <cprintf+0x184>
801004a3:	83 f8 73             	cmp    $0x73,%eax
801004a6:	0f 84 8d 00 00 00    	je     80100539 <cprintf+0x136>
801004ac:	83 f8 78             	cmp    $0x78,%eax
801004af:	74 63                	je     80100514 <cprintf+0x111>
801004b1:	83 f8 70             	cmp    $0x70,%eax
801004b4:	74 5e                	je     80100514 <cprintf+0x111>
801004b6:	e9 cc 00 00 00       	jmp    80100587 <cprintf+0x184>
    case 'd':
      printint(*argp++, 10, 1);
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801004cd:	00 
801004ce:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801004d5:	00 
801004d6:	89 04 24             	mov    %eax,(%esp)
801004d9:	e8 13 fe ff ff       	call   801002f1 <printint>
      break;
801004de:	e9 bc 00 00 00       	jmp    8010059f <cprintf+0x19c>
    case 'l':
        printlong(*(unsigned long long *)argp, 10, 0);
801004e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e6:	8b 50 04             	mov    0x4(%eax),%edx
801004e9:	8b 00                	mov    (%eax),%eax
801004eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801004f2:	00 
801004f3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
801004fa:	00 
801004fb:	89 04 24             	mov    %eax,(%esp)
801004fe:	89 54 24 04          	mov    %edx,0x4(%esp)
80100502:	e8 99 fe ff ff       	call   801003a0 <printlong>
        // long longs take up 2 argument slots
        argp++;
80100507:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
        argp++;
8010050b:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
        break;
8010050f:	e9 8b 00 00 00       	jmp    8010059f <cprintf+0x19c>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100514:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100517:	8d 50 04             	lea    0x4(%eax),%edx
8010051a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010051d:	8b 00                	mov    (%eax),%eax
8010051f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100526:	00 
80100527:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010052e:	00 
8010052f:	89 04 24             	mov    %eax,(%esp)
80100532:	e8 ba fd ff ff       	call   801002f1 <printint>
      break;
80100537:	eb 66                	jmp    8010059f <cprintf+0x19c>
    case 's':
      if((s = (char*)*argp++) == 0)
80100539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053c:	8d 50 04             	lea    0x4(%eax),%edx
8010053f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100542:	8b 00                	mov    (%eax),%eax
80100544:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100547:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054b:	75 09                	jne    80100556 <cprintf+0x153>
        s = "(null)";
8010054d:	c7 45 ec ff 88 10 80 	movl   $0x801088ff,-0x14(%ebp)
      for(; *s; s++)
80100554:	eb 17                	jmp    8010056d <cprintf+0x16a>
80100556:	eb 15                	jmp    8010056d <cprintf+0x16a>
        consputc(*s);
80100558:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010055b:	0f b6 00             	movzbl (%eax),%eax
8010055e:	0f be c0             	movsbl %al,%eax
80100561:	89 04 24             	mov    %eax,(%esp)
80100564:	e8 9f 02 00 00       	call   80100808 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100569:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100570:	0f b6 00             	movzbl (%eax),%eax
80100573:	84 c0                	test   %al,%al
80100575:	75 e1                	jne    80100558 <cprintf+0x155>
        consputc(*s);
      break;
80100577:	eb 26                	jmp    8010059f <cprintf+0x19c>
    case '%':
      consputc('%');
80100579:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
80100580:	e8 83 02 00 00       	call   80100808 <consputc>
      break;
80100585:	eb 18                	jmp    8010059f <cprintf+0x19c>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100587:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010058e:	e8 75 02 00 00       	call   80100808 <consputc>
      consputc(c);
80100593:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100596:	89 04 24             	mov    %eax,(%esp)
80100599:	e8 6a 02 00 00       	call   80100808 <consputc>
      break;
8010059e:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010059f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005a3:	8b 55 08             	mov    0x8(%ebp),%edx
801005a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a9:	01 d0                	add    %edx,%eax
801005ab:	0f b6 00             	movzbl (%eax),%eax
801005ae:	0f be c0             	movsbl %al,%eax
801005b1:	25 ff 00 00 00       	and    $0xff,%eax
801005b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005bd:	0f 85 85 fe ff ff    	jne    80100448 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
801005c3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005c7:	74 0c                	je     801005d5 <cprintf+0x1d2>
    release(&cons.lock);
801005c9:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801005d0:	e8 d8 4a 00 00       	call   801050ad <release>
}
801005d5:	c9                   	leave  
801005d6:	c3                   	ret    

801005d7 <panic>:

void
panic(char *s)
{
801005d7:	55                   	push   %ebp
801005d8:	89 e5                	mov    %esp,%ebp
801005da:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
801005dd:	e8 09 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
801005e2:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
801005e9:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
801005ec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801005f2:	0f b6 00             	movzbl (%eax),%eax
801005f5:	0f b6 c0             	movzbl %al,%eax
801005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801005fc:	c7 04 24 06 89 10 80 	movl   $0x80108906,(%esp)
80100603:	e8 fb fd ff ff       	call   80100403 <cprintf>
  cprintf(s);
80100608:	8b 45 08             	mov    0x8(%ebp),%eax
8010060b:	89 04 24             	mov    %eax,(%esp)
8010060e:	e8 f0 fd ff ff       	call   80100403 <cprintf>
  cprintf("\n");
80100613:	c7 04 24 15 89 10 80 	movl   $0x80108915,(%esp)
8010061a:	e8 e4 fd ff ff       	call   80100403 <cprintf>
  getcallerpcs(&s, pcs);
8010061f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100622:	89 44 24 04          	mov    %eax,0x4(%esp)
80100626:	8d 45 08             	lea    0x8(%ebp),%eax
80100629:	89 04 24             	mov    %eax,(%esp)
8010062c:	e8 cb 4a 00 00       	call   801050fc <getcallerpcs>
  for(i=0; i<10; i++)
80100631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100638:	eb 1b                	jmp    80100655 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010063a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063d:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100641:	89 44 24 04          	mov    %eax,0x4(%esp)
80100645:	c7 04 24 17 89 10 80 	movl   $0x80108917,(%esp)
8010064c:	e8 b2 fd ff ff       	call   80100403 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
80100651:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100655:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100659:	7e df                	jle    8010063a <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
8010065b:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
80100662:	00 00 00 
  for(;;)
    ;
80100665:	eb fe                	jmp    80100665 <panic+0x8e>

80100667 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100667:	55                   	push   %ebp
80100668:	89 e5                	mov    %esp,%ebp
8010066a:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010066d:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100674:	00 
80100675:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010067c:	e8 4c fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
80100681:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100688:	e8 23 fc ff ff       	call   801002b0 <inb>
8010068d:	0f b6 c0             	movzbl %al,%eax
80100690:	c1 e0 08             	shl    $0x8,%eax
80100693:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100696:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010069d:	00 
8010069e:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006a5:	e8 23 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
801006aa:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801006b1:	e8 fa fb ff ff       	call   801002b0 <inb>
801006b6:	0f b6 c0             	movzbl %al,%eax
801006b9:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006bc:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006c0:	75 30                	jne    801006f2 <cgaputc+0x8b>
    pos += 80 - pos%80;
801006c2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006c5:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006ca:	89 c8                	mov    %ecx,%eax
801006cc:	f7 ea                	imul   %edx
801006ce:	c1 fa 05             	sar    $0x5,%edx
801006d1:	89 c8                	mov    %ecx,%eax
801006d3:	c1 f8 1f             	sar    $0x1f,%eax
801006d6:	29 c2                	sub    %eax,%edx
801006d8:	89 d0                	mov    %edx,%eax
801006da:	c1 e0 02             	shl    $0x2,%eax
801006dd:	01 d0                	add    %edx,%eax
801006df:	c1 e0 04             	shl    $0x4,%eax
801006e2:	29 c1                	sub    %eax,%ecx
801006e4:	89 ca                	mov    %ecx,%edx
801006e6:	b8 50 00 00 00       	mov    $0x50,%eax
801006eb:	29 d0                	sub    %edx,%eax
801006ed:	01 45 f4             	add    %eax,-0xc(%ebp)
801006f0:	eb 35                	jmp    80100727 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006f2:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006f9:	75 0c                	jne    80100707 <cgaputc+0xa0>
    if(pos > 0) --pos;
801006fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006ff:	7e 26                	jle    80100727 <cgaputc+0xc0>
80100701:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100705:	eb 20                	jmp    80100727 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100707:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010070d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100710:	8d 50 01             	lea    0x1(%eax),%edx
80100713:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100716:	01 c0                	add    %eax,%eax
80100718:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010071b:	8b 45 08             	mov    0x8(%ebp),%eax
8010071e:	0f b6 c0             	movzbl %al,%eax
80100721:	80 cc 07             	or     $0x7,%ah
80100724:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
80100727:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010072b:	78 09                	js     80100736 <cgaputc+0xcf>
8010072d:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100734:	7e 0c                	jle    80100742 <cgaputc+0xdb>
    panic("pos under/overflow");
80100736:	c7 04 24 1b 89 10 80 	movl   $0x8010891b,(%esp)
8010073d:	e8 95 fe ff ff       	call   801005d7 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
80100742:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100749:	7e 53                	jle    8010079e <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010074b:	a1 00 90 10 80       	mov    0x80109000,%eax
80100750:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100756:	a1 00 90 10 80       	mov    0x80109000,%eax
8010075b:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
80100762:	00 
80100763:	89 54 24 04          	mov    %edx,0x4(%esp)
80100767:	89 04 24             	mov    %eax,(%esp)
8010076a:	e8 ff 4b 00 00       	call   8010536e <memmove>
    pos -= 80;
8010076f:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100773:	b8 80 07 00 00       	mov    $0x780,%eax
80100778:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010077b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010077e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100783:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100786:	01 c9                	add    %ecx,%ecx
80100788:	01 c8                	add    %ecx,%eax
8010078a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010078e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100795:	00 
80100796:	89 04 24             	mov    %eax,(%esp)
80100799:	e8 01 4b 00 00       	call   8010529f <memset>
  }
  
  outb(CRTPORT, 14);
8010079e:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801007a5:	00 
801007a6:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801007ad:	e8 1b fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801007b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007b5:	c1 f8 08             	sar    $0x8,%eax
801007b8:	0f b6 c0             	movzbl %al,%eax
801007bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801007bf:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007c6:	e8 02 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
801007cb:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801007d2:	00 
801007d3:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801007da:	e8 ee fa ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
801007df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e2:	0f b6 c0             	movzbl %al,%eax
801007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801007e9:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007f0:	e8 d8 fa ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
801007f5:	a1 00 90 10 80       	mov    0x80109000,%eax
801007fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007fd:	01 d2                	add    %edx,%edx
801007ff:	01 d0                	add    %edx,%eax
80100801:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100806:	c9                   	leave  
80100807:	c3                   	ret    

80100808 <consputc>:

void
consputc(int c)
{
80100808:	55                   	push   %ebp
80100809:	89 e5                	mov    %esp,%ebp
8010080b:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010080e:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100813:	85 c0                	test   %eax,%eax
80100815:	74 07                	je     8010081e <consputc+0x16>
    cli();
80100817:	e8 cf fa ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010081c:	eb fe                	jmp    8010081c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010081e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100825:	75 26                	jne    8010084d <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100827:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010082e:	e8 a0 64 00 00       	call   80106cd3 <uartputc>
80100833:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010083a:	e8 94 64 00 00       	call   80106cd3 <uartputc>
8010083f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100846:	e8 88 64 00 00       	call   80106cd3 <uartputc>
8010084b:	eb 0b                	jmp    80100858 <consputc+0x50>
  } else
    uartputc(c);
8010084d:	8b 45 08             	mov    0x8(%ebp),%eax
80100850:	89 04 24             	mov    %eax,(%esp)
80100853:	e8 7b 64 00 00       	call   80106cd3 <uartputc>
  cgaputc(c);
80100858:	8b 45 08             	mov    0x8(%ebp),%eax
8010085b:	89 04 24             	mov    %eax,(%esp)
8010085e:	e8 04 fe ff ff       	call   80100667 <cgaputc>
}
80100863:	c9                   	leave  
80100864:	c3                   	ret    

80100865 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100865:	55                   	push   %ebp
80100866:	89 e5                	mov    %esp,%ebp
80100868:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
8010086b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100872:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100879:	e8 cd 47 00 00       	call   8010504b <acquire>
  while((c = getc()) >= 0){
8010087e:	e9 39 01 00 00       	jmp    801009bc <consoleintr+0x157>
    switch(c){
80100883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100886:	83 f8 10             	cmp    $0x10,%eax
80100889:	74 1e                	je     801008a9 <consoleintr+0x44>
8010088b:	83 f8 10             	cmp    $0x10,%eax
8010088e:	7f 0a                	jg     8010089a <consoleintr+0x35>
80100890:	83 f8 08             	cmp    $0x8,%eax
80100893:	74 66                	je     801008fb <consoleintr+0x96>
80100895:	e9 93 00 00 00       	jmp    8010092d <consoleintr+0xc8>
8010089a:	83 f8 15             	cmp    $0x15,%eax
8010089d:	74 31                	je     801008d0 <consoleintr+0x6b>
8010089f:	83 f8 7f             	cmp    $0x7f,%eax
801008a2:	74 57                	je     801008fb <consoleintr+0x96>
801008a4:	e9 84 00 00 00       	jmp    8010092d <consoleintr+0xc8>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
801008a9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
801008b0:	e9 07 01 00 00       	jmp    801009bc <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008b5:	a1 e8 11 11 80       	mov    0x801111e8,%eax
801008ba:	83 e8 01             	sub    $0x1,%eax
801008bd:	a3 e8 11 11 80       	mov    %eax,0x801111e8
        consputc(BACKSPACE);
801008c2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008c9:	e8 3a ff ff ff       	call   80100808 <consputc>
801008ce:	eb 01                	jmp    801008d1 <consoleintr+0x6c>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008d0:	90                   	nop
801008d1:	8b 15 e8 11 11 80    	mov    0x801111e8,%edx
801008d7:	a1 e4 11 11 80       	mov    0x801111e4,%eax
801008dc:	39 c2                	cmp    %eax,%edx
801008de:	74 16                	je     801008f6 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008e0:	a1 e8 11 11 80       	mov    0x801111e8,%eax
801008e5:	83 e8 01             	sub    $0x1,%eax
801008e8:	83 e0 7f             	and    $0x7f,%eax
801008eb:	0f b6 80 60 11 11 80 	movzbl -0x7feeeea0(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008f2:	3c 0a                	cmp    $0xa,%al
801008f4:	75 bf                	jne    801008b5 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008f6:	e9 c1 00 00 00       	jmp    801009bc <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008fb:	8b 15 e8 11 11 80    	mov    0x801111e8,%edx
80100901:	a1 e4 11 11 80       	mov    0x801111e4,%eax
80100906:	39 c2                	cmp    %eax,%edx
80100908:	74 1e                	je     80100928 <consoleintr+0xc3>
        input.e--;
8010090a:	a1 e8 11 11 80       	mov    0x801111e8,%eax
8010090f:	83 e8 01             	sub    $0x1,%eax
80100912:	a3 e8 11 11 80       	mov    %eax,0x801111e8
        consputc(BACKSPACE);
80100917:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010091e:	e8 e5 fe ff ff       	call   80100808 <consputc>
      }
      break;
80100923:	e9 94 00 00 00       	jmp    801009bc <consoleintr+0x157>
80100928:	e9 8f 00 00 00       	jmp    801009bc <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010092d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100931:	0f 84 84 00 00 00    	je     801009bb <consoleintr+0x156>
80100937:	8b 15 e8 11 11 80    	mov    0x801111e8,%edx
8010093d:	a1 e0 11 11 80       	mov    0x801111e0,%eax
80100942:	29 c2                	sub    %eax,%edx
80100944:	89 d0                	mov    %edx,%eax
80100946:	83 f8 7f             	cmp    $0x7f,%eax
80100949:	77 70                	ja     801009bb <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
8010094b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010094f:	74 05                	je     80100956 <consoleintr+0xf1>
80100951:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100954:	eb 05                	jmp    8010095b <consoleintr+0xf6>
80100956:	b8 0a 00 00 00       	mov    $0xa,%eax
8010095b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010095e:	a1 e8 11 11 80       	mov    0x801111e8,%eax
80100963:	8d 50 01             	lea    0x1(%eax),%edx
80100966:	89 15 e8 11 11 80    	mov    %edx,0x801111e8
8010096c:	83 e0 7f             	and    $0x7f,%eax
8010096f:	89 c2                	mov    %eax,%edx
80100971:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100974:	88 82 60 11 11 80    	mov    %al,-0x7feeeea0(%edx)
        consputc(c);
8010097a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010097d:	89 04 24             	mov    %eax,(%esp)
80100980:	e8 83 fe ff ff       	call   80100808 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100985:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100989:	74 18                	je     801009a3 <consoleintr+0x13e>
8010098b:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
8010098f:	74 12                	je     801009a3 <consoleintr+0x13e>
80100991:	a1 e8 11 11 80       	mov    0x801111e8,%eax
80100996:	8b 15 e0 11 11 80    	mov    0x801111e0,%edx
8010099c:	83 ea 80             	sub    $0xffffff80,%edx
8010099f:	39 d0                	cmp    %edx,%eax
801009a1:	75 18                	jne    801009bb <consoleintr+0x156>
          input.w = input.e;
801009a3:	a1 e8 11 11 80       	mov    0x801111e8,%eax
801009a8:	a3 e4 11 11 80       	mov    %eax,0x801111e4
          wakeup(&input.r);
801009ad:	c7 04 24 e0 11 11 80 	movl   $0x801111e0,(%esp)
801009b4:	e8 97 44 00 00       	call   80104e50 <wakeup>
        }
      }
      break;
801009b9:	eb 00                	jmp    801009bb <consoleintr+0x156>
801009bb:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009bc:	8b 45 08             	mov    0x8(%ebp),%eax
801009bf:	ff d0                	call   *%eax
801009c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009c8:	0f 89 b5 fe ff ff    	jns    80100883 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009ce:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801009d5:	e8 d3 46 00 00       	call   801050ad <release>
  if(doprocdump) {
801009da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009de:	74 05                	je     801009e5 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
801009e0:	e8 0e 45 00 00       	call   80104ef3 <procdump>
  }
}
801009e5:	c9                   	leave  
801009e6:	c3                   	ret    

801009e7 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009e7:	55                   	push   %ebp
801009e8:	89 e5                	mov    %esp,%ebp
801009ea:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
801009ed:	8b 45 08             	mov    0x8(%ebp),%eax
801009f0:	89 04 24             	mov    %eax,(%esp)
801009f3:	e8 cd 10 00 00       	call   80101ac5 <iunlock>
  target = n;
801009f8:	8b 45 10             	mov    0x10(%ebp),%eax
801009fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009fe:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a05:	e8 41 46 00 00       	call   8010504b <acquire>
  while(n > 0){
80100a0a:	e9 aa 00 00 00       	jmp    80100ab9 <consoleread+0xd2>
    while(input.r == input.w){
80100a0f:	eb 42                	jmp    80100a53 <consoleread+0x6c>
      if(proc->killed){
80100a11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a17:	8b 40 24             	mov    0x24(%eax),%eax
80100a1a:	85 c0                	test   %eax,%eax
80100a1c:	74 21                	je     80100a3f <consoleread+0x58>
        release(&cons.lock);
80100a1e:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a25:	e8 83 46 00 00       	call   801050ad <release>
        ilock(ip);
80100a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2d:	89 04 24             	mov    %eax,(%esp)
80100a30:	e8 3c 0f 00 00       	call   80101971 <ilock>
        return -1;
80100a35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a3a:	e9 a5 00 00 00       	jmp    80100ae4 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
80100a3f:	c7 44 24 04 e0 b5 10 	movl   $0x8010b5e0,0x4(%esp)
80100a46:	80 
80100a47:	c7 04 24 e0 11 11 80 	movl   $0x801111e0,(%esp)
80100a4e:	e8 24 43 00 00       	call   80104d77 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a53:	8b 15 e0 11 11 80    	mov    0x801111e0,%edx
80100a59:	a1 e4 11 11 80       	mov    0x801111e4,%eax
80100a5e:	39 c2                	cmp    %eax,%edx
80100a60:	74 af                	je     80100a11 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a62:	a1 e0 11 11 80       	mov    0x801111e0,%eax
80100a67:	8d 50 01             	lea    0x1(%eax),%edx
80100a6a:	89 15 e0 11 11 80    	mov    %edx,0x801111e0
80100a70:	83 e0 7f             	and    $0x7f,%eax
80100a73:	0f b6 80 60 11 11 80 	movzbl -0x7feeeea0(%eax),%eax
80100a7a:	0f be c0             	movsbl %al,%eax
80100a7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a80:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a84:	75 19                	jne    80100a9f <consoleread+0xb8>
      if(n < target){
80100a86:	8b 45 10             	mov    0x10(%ebp),%eax
80100a89:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a8c:	73 0f                	jae    80100a9d <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a8e:	a1 e0 11 11 80       	mov    0x801111e0,%eax
80100a93:	83 e8 01             	sub    $0x1,%eax
80100a96:	a3 e0 11 11 80       	mov    %eax,0x801111e0
      }
      break;
80100a9b:	eb 26                	jmp    80100ac3 <consoleread+0xdc>
80100a9d:	eb 24                	jmp    80100ac3 <consoleread+0xdc>
    }
    *dst++ = c;
80100a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa2:	8d 50 01             	lea    0x1(%eax),%edx
80100aa5:	89 55 0c             	mov    %edx,0xc(%ebp)
80100aa8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100aab:	88 10                	mov    %dl,(%eax)
    --n;
80100aad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100ab1:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ab5:	75 02                	jne    80100ab9 <consoleread+0xd2>
      break;
80100ab7:	eb 0a                	jmp    80100ac3 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100ab9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100abd:	0f 8f 4c ff ff ff    	jg     80100a0f <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100ac3:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100aca:	e8 de 45 00 00       	call   801050ad <release>
  ilock(ip);
80100acf:	8b 45 08             	mov    0x8(%ebp),%eax
80100ad2:	89 04 24             	mov    %eax,(%esp)
80100ad5:	e8 97 0e 00 00       	call   80101971 <ilock>

  return target - n;
80100ada:	8b 45 10             	mov    0x10(%ebp),%eax
80100add:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ae0:	29 c2                	sub    %eax,%edx
80100ae2:	89 d0                	mov    %edx,%eax
}
80100ae4:	c9                   	leave  
80100ae5:	c3                   	ret    

80100ae6 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ae6:	55                   	push   %ebp
80100ae7:	89 e5                	mov    %esp,%ebp
80100ae9:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100aec:	8b 45 08             	mov    0x8(%ebp),%eax
80100aef:	89 04 24             	mov    %eax,(%esp)
80100af2:	e8 ce 0f 00 00       	call   80101ac5 <iunlock>
  acquire(&cons.lock);
80100af7:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100afe:	e8 48 45 00 00       	call   8010504b <acquire>
  for(i = 0; i < n; i++)
80100b03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b0a:	eb 1d                	jmp    80100b29 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100b0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b12:	01 d0                	add    %edx,%eax
80100b14:	0f b6 00             	movzbl (%eax),%eax
80100b17:	0f be c0             	movsbl %al,%eax
80100b1a:	0f b6 c0             	movzbl %al,%eax
80100b1d:	89 04 24             	mov    %eax,(%esp)
80100b20:	e8 e3 fc ff ff       	call   80100808 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b2c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b2f:	7c db                	jl     80100b0c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b31:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100b38:	e8 70 45 00 00       	call   801050ad <release>
  ilock(ip);
80100b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80100b40:	89 04 24             	mov    %eax,(%esp)
80100b43:	e8 29 0e 00 00       	call   80101971 <ilock>

  return n;
80100b48:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b4b:	c9                   	leave  
80100b4c:	c3                   	ret    

80100b4d <consoleinit>:

void
consoleinit(void)
{
80100b4d:	55                   	push   %ebp
80100b4e:	89 e5                	mov    %esp,%ebp
80100b50:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100b53:	c7 44 24 04 2e 89 10 	movl   $0x8010892e,0x4(%esp)
80100b5a:	80 
80100b5b:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100b62:	e8 c3 44 00 00       	call   8010502a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100b67:	c7 05 ac 1b 11 80 e6 	movl   $0x80100ae6,0x80111bac
80100b6e:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b71:	c7 05 a8 1b 11 80 e7 	movl   $0x801009e7,0x80111ba8
80100b78:	09 10 80 
  cons.locking = 1;
80100b7b:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100b82:	00 00 00 

  picenable(IRQ_KBD);
80100b85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b8c:	e8 bf 33 00 00       	call   80103f50 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100b91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100b98:	00 
80100b99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ba0:	e8 0b 1f 00 00       	call   80102ab0 <ioapicenable>
}
80100ba5:	c9                   	leave  
80100ba6:	c3                   	ret    

80100ba7 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ba7:	55                   	push   %ebp
80100ba8:	89 e5                	mov    %esp,%ebp
80100baa:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100bb0:	e8 fc 29 00 00       	call   801035b1 <begin_op>
  if((ip = namei(path)) == 0){
80100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80100bb8:	89 04 24             	mov    %eax,(%esp)
80100bbb:	e8 62 19 00 00       	call   80102522 <namei>
80100bc0:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bc3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc7:	75 0f                	jne    80100bd8 <exec+0x31>
    end_op();
80100bc9:	e8 67 2a 00 00       	call   80103635 <end_op>
    return -1;
80100bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd3:	e9 e8 03 00 00       	jmp    80100fc0 <exec+0x419>
  }
  ilock(ip);
80100bd8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bdb:	89 04 24             	mov    %eax,(%esp)
80100bde:	e8 8e 0d 00 00       	call   80101971 <ilock>
  pgdir = 0;
80100be3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bea:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100bf1:	00 
80100bf2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100bf9:	00 
80100bfa:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c04:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c07:	89 04 24             	mov    %eax,(%esp)
80100c0a:	e8 75 12 00 00       	call   80101e84 <readi>
80100c0f:	83 f8 33             	cmp    $0x33,%eax
80100c12:	77 05                	ja     80100c19 <exec+0x72>
    goto bad;
80100c14:	e9 7b 03 00 00       	jmp    80100f94 <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100c19:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c1f:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c24:	74 05                	je     80100c2b <exec+0x84>
    goto bad;
80100c26:	e9 69 03 00 00       	jmp    80100f94 <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100c2b:	e8 34 74 00 00       	call   80108064 <setupkvm>
80100c30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c33:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c37:	75 05                	jne    80100c3e <exec+0x97>
    goto bad;
80100c39:	e9 56 03 00 00       	jmp    80100f94 <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100c3e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c45:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c4c:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c52:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c55:	e9 cb 00 00 00       	jmp    80100d25 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c5d:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100c64:	00 
80100c65:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c69:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c73:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c76:	89 04 24             	mov    %eax,(%esp)
80100c79:	e8 06 12 00 00       	call   80101e84 <readi>
80100c7e:	83 f8 20             	cmp    $0x20,%eax
80100c81:	74 05                	je     80100c88 <exec+0xe1>
      goto bad;
80100c83:	e9 0c 03 00 00       	jmp    80100f94 <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100c88:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c8e:	83 f8 01             	cmp    $0x1,%eax
80100c91:	74 05                	je     80100c98 <exec+0xf1>
      continue;
80100c93:	e9 80 00 00 00       	jmp    80100d18 <exec+0x171>
    if(ph.memsz < ph.filesz)
80100c98:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c9e:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca4:	39 c2                	cmp    %eax,%edx
80100ca6:	73 05                	jae    80100cad <exec+0x106>
      goto bad;
80100ca8:	e9 e7 02 00 00       	jmp    80100f94 <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cad:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100cb3:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100cb9:	01 d0                	add    %edx,%eax
80100cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cc6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cc9:	89 04 24             	mov    %eax,(%esp)
80100ccc:	e8 61 77 00 00       	call   80108432 <allocuvm>
80100cd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd8:	75 05                	jne    80100cdf <exec+0x138>
      goto bad;
80100cda:	e9 b5 02 00 00       	jmp    80100f94 <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100ce5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ceb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100cf1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100cf5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100cf9:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100cfc:	89 54 24 08          	mov    %edx,0x8(%esp)
80100d00:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d07:	89 04 24             	mov    %eax,(%esp)
80100d0a:	e8 38 76 00 00       	call   80108347 <loaduvm>
80100d0f:	85 c0                	test   %eax,%eax
80100d11:	79 05                	jns    80100d18 <exec+0x171>
      goto bad;
80100d13:	e9 7c 02 00 00       	jmp    80100f94 <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d18:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d1f:	83 c0 20             	add    $0x20,%eax
80100d22:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d25:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d2c:	0f b7 c0             	movzwl %ax,%eax
80100d2f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d32:	0f 8f 22 ff ff ff    	jg     80100c5a <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d38:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d3b:	89 04 24             	mov    %eax,(%esp)
80100d3e:	e8 b8 0e 00 00       	call   80101bfb <iunlockput>
  end_op();
80100d43:	e8 ed 28 00 00       	call   80103635 <end_op>
  ip = 0;
80100d48:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d52:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d62:	05 00 20 00 00       	add    $0x2000,%eax
80100d67:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d75:	89 04 24             	mov    %eax,(%esp)
80100d78:	e8 b5 76 00 00       	call   80108432 <allocuvm>
80100d7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d80:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d84:	75 05                	jne    80100d8b <exec+0x1e4>
    goto bad;
80100d86:	e9 09 02 00 00       	jmp    80100f94 <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d93:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d9a:	89 04 24             	mov    %eax,(%esp)
80100d9d:	e8 c0 78 00 00       	call   80108662 <clearpteu>
  sp = sz;
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100daf:	e9 9a 00 00 00       	jmp    80100e4e <exec+0x2a7>
    if(argc >= MAXARG)
80100db4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100db8:	76 05                	jbe    80100dbf <exec+0x218>
      goto bad;
80100dba:	e9 d5 01 00 00       	jmp    80100f94 <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcc:	01 d0                	add    %edx,%eax
80100dce:	8b 00                	mov    (%eax),%eax
80100dd0:	89 04 24             	mov    %eax,(%esp)
80100dd3:	e8 31 47 00 00       	call   80105509 <strlen>
80100dd8:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ddb:	29 c2                	sub    %eax,%edx
80100ddd:	89 d0                	mov    %edx,%eax
80100ddf:	83 e8 01             	sub    $0x1,%eax
80100de2:	83 e0 fc             	and    $0xfffffffc,%eax
80100de5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100deb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df5:	01 d0                	add    %edx,%eax
80100df7:	8b 00                	mov    (%eax),%eax
80100df9:	89 04 24             	mov    %eax,(%esp)
80100dfc:	e8 08 47 00 00       	call   80105509 <strlen>
80100e01:	83 c0 01             	add    $0x1,%eax
80100e04:	89 c2                	mov    %eax,%edx
80100e06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e09:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e10:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e13:	01 c8                	add    %ecx,%eax
80100e15:	8b 00                	mov    (%eax),%eax
80100e17:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100e1b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e22:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e29:	89 04 24             	mov    %eax,(%esp)
80100e2c:	e8 f6 79 00 00       	call   80108827 <copyout>
80100e31:	85 c0                	test   %eax,%eax
80100e33:	79 05                	jns    80100e3a <exec+0x293>
      goto bad;
80100e35:	e9 5a 01 00 00       	jmp    80100f94 <exec+0x3ed>
    ustack[3+argc] = sp;
80100e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3d:	8d 50 03             	lea    0x3(%eax),%edx
80100e40:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e43:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e4a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e51:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e5b:	01 d0                	add    %edx,%eax
80100e5d:	8b 00                	mov    (%eax),%eax
80100e5f:	85 c0                	test   %eax,%eax
80100e61:	0f 85 4d ff ff ff    	jne    80100db4 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6a:	83 c0 03             	add    $0x3,%eax
80100e6d:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e74:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e78:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e7f:	ff ff ff 
  ustack[1] = argc;
80100e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e85:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8e:	83 c0 01             	add    $0x1,%eax
80100e91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e98:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e9b:	29 d0                	sub    %edx,%eax
80100e9d:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ea3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea6:	83 c0 04             	add    $0x4,%eax
80100ea9:	c1 e0 02             	shl    $0x2,%eax
80100eac:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb2:	83 c0 04             	add    $0x4,%eax
80100eb5:	c1 e0 02             	shl    $0x2,%eax
80100eb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100ebc:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100ec2:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ec6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ecd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ed0:	89 04 24             	mov    %eax,(%esp)
80100ed3:	e8 4f 79 00 00       	call   80108827 <copyout>
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	79 05                	jns    80100ee1 <exec+0x33a>
    goto bad;
80100edc:	e9 b3 00 00 00       	jmp    80100f94 <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80100ee4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100eed:	eb 17                	jmp    80100f06 <exec+0x35f>
    if(*s == '/')
80100eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef2:	0f b6 00             	movzbl (%eax),%eax
80100ef5:	3c 2f                	cmp    $0x2f,%al
80100ef7:	75 09                	jne    80100f02 <exec+0x35b>
      last = s+1;
80100ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efc:	83 c0 01             	add    $0x1,%eax
80100eff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f09:	0f b6 00             	movzbl (%eax),%eax
80100f0c:	84 c0                	test   %al,%al
80100f0e:	75 df                	jne    80100eef <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f16:	8d 50 6c             	lea    0x6c(%eax),%edx
80100f19:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100f20:	00 
80100f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100f24:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f28:	89 14 24             	mov    %edx,(%esp)
80100f2b:	e8 8f 45 00 00       	call   801054bf <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100f30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f36:	8b 40 04             	mov    0x4(%eax),%eax
80100f39:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f42:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f45:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f51:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f59:	8b 40 18             	mov    0x18(%eax),%eax
80100f5c:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f62:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f6b:	8b 40 18             	mov    0x18(%eax),%eax
80100f6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f71:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f7a:	89 04 24             	mov    %eax,(%esp)
80100f7d:	e8 d3 71 00 00       	call   80108155 <switchuvm>
  freevm(oldpgdir);
80100f82:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f85:	89 04 24             	mov    %eax,(%esp)
80100f88:	e8 3b 76 00 00       	call   801085c8 <freevm>
  return 0;
80100f8d:	b8 00 00 00 00       	mov    $0x0,%eax
80100f92:	eb 2c                	jmp    80100fc0 <exec+0x419>

 bad:
  if(pgdir)
80100f94:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f98:	74 0b                	je     80100fa5 <exec+0x3fe>
    freevm(pgdir);
80100f9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f9d:	89 04 24             	mov    %eax,(%esp)
80100fa0:	e8 23 76 00 00       	call   801085c8 <freevm>
  if(ip){
80100fa5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa9:	74 10                	je     80100fbb <exec+0x414>
    iunlockput(ip);
80100fab:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fae:	89 04 24             	mov    %eax,(%esp)
80100fb1:	e8 45 0c 00 00       	call   80101bfb <iunlockput>
    end_op();
80100fb6:	e8 7a 26 00 00       	call   80103635 <end_op>
  }
  return -1;
80100fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc0:	c9                   	leave  
80100fc1:	c3                   	ret    

80100fc2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc2:	55                   	push   %ebp
80100fc3:	89 e5                	mov    %esp,%ebp
80100fc5:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100fc8:	c7 44 24 04 36 89 10 	movl   $0x80108936,0x4(%esp)
80100fcf:	80 
80100fd0:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
80100fd7:	e8 4e 40 00 00       	call   8010502a <initlock>
}
80100fdc:	c9                   	leave  
80100fdd:	c3                   	ret    

80100fde <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fde:	55                   	push   %ebp
80100fdf:	89 e5                	mov    %esp,%ebp
80100fe1:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe4:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
80100feb:	e8 5b 40 00 00       	call   8010504b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff0:	c7 45 f4 34 12 11 80 	movl   $0x80111234,-0xc(%ebp)
80100ff7:	eb 29                	jmp    80101022 <filealloc+0x44>
    if(f->ref == 0){
80100ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ffc:	8b 40 04             	mov    0x4(%eax),%eax
80100fff:	85 c0                	test   %eax,%eax
80101001:	75 1b                	jne    8010101e <filealloc+0x40>
      f->ref = 1;
80101003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101006:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010100d:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
80101014:	e8 94 40 00 00       	call   801050ad <release>
      return f;
80101019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010101c:	eb 1e                	jmp    8010103c <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010101e:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101022:	81 7d f4 94 1b 11 80 	cmpl   $0x80111b94,-0xc(%ebp)
80101029:	72 ce                	jb     80100ff9 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010102b:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
80101032:	e8 76 40 00 00       	call   801050ad <release>
  return 0;
80101037:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010103c:	c9                   	leave  
8010103d:	c3                   	ret    

8010103e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010103e:	55                   	push   %ebp
8010103f:	89 e5                	mov    %esp,%ebp
80101041:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101044:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
8010104b:	e8 fb 3f 00 00       	call   8010504b <acquire>
  if(f->ref < 1)
80101050:	8b 45 08             	mov    0x8(%ebp),%eax
80101053:	8b 40 04             	mov    0x4(%eax),%eax
80101056:	85 c0                	test   %eax,%eax
80101058:	7f 0c                	jg     80101066 <filedup+0x28>
    panic("filedup");
8010105a:	c7 04 24 3d 89 10 80 	movl   $0x8010893d,(%esp)
80101061:	e8 71 f5 ff ff       	call   801005d7 <panic>
  f->ref++;
80101066:	8b 45 08             	mov    0x8(%ebp),%eax
80101069:	8b 40 04             	mov    0x4(%eax),%eax
8010106c:	8d 50 01             	lea    0x1(%eax),%edx
8010106f:	8b 45 08             	mov    0x8(%ebp),%eax
80101072:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101075:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
8010107c:	e8 2c 40 00 00       	call   801050ad <release>
  return f;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101084:	c9                   	leave  
80101085:	c3                   	ret    

80101086 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101086:	55                   	push   %ebp
80101087:	89 e5                	mov    %esp,%ebp
80101089:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
8010108c:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
80101093:	e8 b3 3f 00 00       	call   8010504b <acquire>
  if(f->ref < 1)
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	8b 40 04             	mov    0x4(%eax),%eax
8010109e:	85 c0                	test   %eax,%eax
801010a0:	7f 0c                	jg     801010ae <fileclose+0x28>
    panic("fileclose");
801010a2:	c7 04 24 45 89 10 80 	movl   $0x80108945,(%esp)
801010a9:	e8 29 f5 ff ff       	call   801005d7 <panic>
  if(--f->ref > 0){
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	89 50 04             	mov    %edx,0x4(%eax)
801010bd:	8b 45 08             	mov    0x8(%ebp),%eax
801010c0:	8b 40 04             	mov    0x4(%eax),%eax
801010c3:	85 c0                	test   %eax,%eax
801010c5:	7e 11                	jle    801010d8 <fileclose+0x52>
    release(&ftable.lock);
801010c7:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
801010ce:	e8 da 3f 00 00       	call   801050ad <release>
801010d3:	e9 82 00 00 00       	jmp    8010115a <fileclose+0xd4>
    return;
  }
  ff = *f;
801010d8:	8b 45 08             	mov    0x8(%ebp),%eax
801010db:	8b 10                	mov    (%eax),%edx
801010dd:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e0:	8b 50 04             	mov    0x4(%eax),%edx
801010e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010e6:	8b 50 08             	mov    0x8(%eax),%edx
801010e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010ec:	8b 50 0c             	mov    0xc(%eax),%edx
801010ef:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f2:	8b 50 10             	mov    0x10(%eax),%edx
801010f5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010f8:	8b 40 14             	mov    0x14(%eax),%eax
801010fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101101:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101108:	8b 45 08             	mov    0x8(%ebp),%eax
8010110b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101111:	c7 04 24 00 12 11 80 	movl   $0x80111200,(%esp)
80101118:	e8 90 3f 00 00       	call   801050ad <release>
  
  if(ff.type == FD_PIPE)
8010111d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101120:	83 f8 01             	cmp    $0x1,%eax
80101123:	75 18                	jne    8010113d <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101125:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101129:	0f be d0             	movsbl %al,%edx
8010112c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010112f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101133:	89 04 24             	mov    %eax,(%esp)
80101136:	e8 c5 30 00 00       	call   80104200 <pipeclose>
8010113b:	eb 1d                	jmp    8010115a <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010113d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101140:	83 f8 02             	cmp    $0x2,%eax
80101143:	75 15                	jne    8010115a <fileclose+0xd4>
    begin_op();
80101145:	e8 67 24 00 00       	call   801035b1 <begin_op>
    iput(ff.ip);
8010114a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010114d:	89 04 24             	mov    %eax,(%esp)
80101150:	e8 d5 09 00 00       	call   80101b2a <iput>
    end_op();
80101155:	e8 db 24 00 00       	call   80103635 <end_op>
  }
}
8010115a:	c9                   	leave  
8010115b:	c3                   	ret    

8010115c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010115c:	55                   	push   %ebp
8010115d:	89 e5                	mov    %esp,%ebp
8010115f:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101162:	8b 45 08             	mov    0x8(%ebp),%eax
80101165:	8b 00                	mov    (%eax),%eax
80101167:	83 f8 02             	cmp    $0x2,%eax
8010116a:	75 38                	jne    801011a4 <filestat+0x48>
    ilock(f->ip);
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 40 10             	mov    0x10(%eax),%eax
80101172:	89 04 24             	mov    %eax,(%esp)
80101175:	e8 f7 07 00 00       	call   80101971 <ilock>
    stati(f->ip, st);
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 40 10             	mov    0x10(%eax),%eax
80101180:	8b 55 0c             	mov    0xc(%ebp),%edx
80101183:	89 54 24 04          	mov    %edx,0x4(%esp)
80101187:	89 04 24             	mov    %eax,(%esp)
8010118a:	e8 b0 0c 00 00       	call   80101e3f <stati>
    iunlock(f->ip);
8010118f:	8b 45 08             	mov    0x8(%ebp),%eax
80101192:	8b 40 10             	mov    0x10(%eax),%eax
80101195:	89 04 24             	mov    %eax,(%esp)
80101198:	e8 28 09 00 00       	call   80101ac5 <iunlock>
    return 0;
8010119d:	b8 00 00 00 00       	mov    $0x0,%eax
801011a2:	eb 05                	jmp    801011a9 <filestat+0x4d>
  }
  return -1;
801011a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011a9:	c9                   	leave  
801011aa:	c3                   	ret    

801011ab <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011ab:	55                   	push   %ebp
801011ac:	89 e5                	mov    %esp,%ebp
801011ae:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801011b1:	8b 45 08             	mov    0x8(%ebp),%eax
801011b4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011b8:	84 c0                	test   %al,%al
801011ba:	75 0a                	jne    801011c6 <fileread+0x1b>
    return -1;
801011bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011c1:	e9 9f 00 00 00       	jmp    80101265 <fileread+0xba>
  if(f->type == FD_PIPE)
801011c6:	8b 45 08             	mov    0x8(%ebp),%eax
801011c9:	8b 00                	mov    (%eax),%eax
801011cb:	83 f8 01             	cmp    $0x1,%eax
801011ce:	75 1e                	jne    801011ee <fileread+0x43>
    return piperead(f->pipe, addr, n);
801011d0:	8b 45 08             	mov    0x8(%ebp),%eax
801011d3:	8b 40 0c             	mov    0xc(%eax),%eax
801011d6:	8b 55 10             	mov    0x10(%ebp),%edx
801011d9:	89 54 24 08          	mov    %edx,0x8(%esp)
801011dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801011e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801011e4:	89 04 24             	mov    %eax,(%esp)
801011e7:	e8 95 31 00 00       	call   80104381 <piperead>
801011ec:	eb 77                	jmp    80101265 <fileread+0xba>
  if(f->type == FD_INODE){
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	8b 00                	mov    (%eax),%eax
801011f3:	83 f8 02             	cmp    $0x2,%eax
801011f6:	75 61                	jne    80101259 <fileread+0xae>
    ilock(f->ip);
801011f8:	8b 45 08             	mov    0x8(%ebp),%eax
801011fb:	8b 40 10             	mov    0x10(%eax),%eax
801011fe:	89 04 24             	mov    %eax,(%esp)
80101201:	e8 6b 07 00 00       	call   80101971 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101206:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 50 14             	mov    0x14(%eax),%edx
8010120f:	8b 45 08             	mov    0x8(%ebp),%eax
80101212:	8b 40 10             	mov    0x10(%eax),%eax
80101215:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101219:	89 54 24 08          	mov    %edx,0x8(%esp)
8010121d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101220:	89 54 24 04          	mov    %edx,0x4(%esp)
80101224:	89 04 24             	mov    %eax,(%esp)
80101227:	e8 58 0c 00 00       	call   80101e84 <readi>
8010122c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010122f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101233:	7e 11                	jle    80101246 <fileread+0x9b>
      f->off += r;
80101235:	8b 45 08             	mov    0x8(%ebp),%eax
80101238:	8b 50 14             	mov    0x14(%eax),%edx
8010123b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010123e:	01 c2                	add    %eax,%edx
80101240:	8b 45 08             	mov    0x8(%ebp),%eax
80101243:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101246:	8b 45 08             	mov    0x8(%ebp),%eax
80101249:	8b 40 10             	mov    0x10(%eax),%eax
8010124c:	89 04 24             	mov    %eax,(%esp)
8010124f:	e8 71 08 00 00       	call   80101ac5 <iunlock>
    return r;
80101254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101257:	eb 0c                	jmp    80101265 <fileread+0xba>
  }
  panic("fileread");
80101259:	c7 04 24 4f 89 10 80 	movl   $0x8010894f,(%esp)
80101260:	e8 72 f3 ff ff       	call   801005d7 <panic>
}
80101265:	c9                   	leave  
80101266:	c3                   	ret    

80101267 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101267:	55                   	push   %ebp
80101268:	89 e5                	mov    %esp,%ebp
8010126a:	53                   	push   %ebx
8010126b:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101275:	84 c0                	test   %al,%al
80101277:	75 0a                	jne    80101283 <filewrite+0x1c>
    return -1;
80101279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010127e:	e9 20 01 00 00       	jmp    801013a3 <filewrite+0x13c>
  if(f->type == FD_PIPE)
80101283:	8b 45 08             	mov    0x8(%ebp),%eax
80101286:	8b 00                	mov    (%eax),%eax
80101288:	83 f8 01             	cmp    $0x1,%eax
8010128b:	75 21                	jne    801012ae <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
8010128d:	8b 45 08             	mov    0x8(%ebp),%eax
80101290:	8b 40 0c             	mov    0xc(%eax),%eax
80101293:	8b 55 10             	mov    0x10(%ebp),%edx
80101296:	89 54 24 08          	mov    %edx,0x8(%esp)
8010129a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010129d:	89 54 24 04          	mov    %edx,0x4(%esp)
801012a1:	89 04 24             	mov    %eax,(%esp)
801012a4:	e8 e9 2f 00 00       	call   80104292 <pipewrite>
801012a9:	e9 f5 00 00 00       	jmp    801013a3 <filewrite+0x13c>
  if(f->type == FD_INODE){
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 02             	cmp    $0x2,%eax
801012b6:	0f 85 db 00 00 00    	jne    80101397 <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012bc:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012ca:	e9 a8 00 00 00       	jmp    80101377 <filewrite+0x110>
      int n1 = n - i;
801012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d2:	8b 55 10             	mov    0x10(%ebp),%edx
801012d5:	29 c2                	sub    %eax,%edx
801012d7:	89 d0                	mov    %edx,%eax
801012d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012e2:	7e 06                	jle    801012ea <filewrite+0x83>
        n1 = max;
801012e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012e7:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012ea:	e8 c2 22 00 00       	call   801035b1 <begin_op>
      ilock(f->ip);
801012ef:	8b 45 08             	mov    0x8(%ebp),%eax
801012f2:	8b 40 10             	mov    0x10(%eax),%eax
801012f5:	89 04 24             	mov    %eax,(%esp)
801012f8:	e8 74 06 00 00       	call   80101971 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012fd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101300:	8b 45 08             	mov    0x8(%ebp),%eax
80101303:	8b 50 14             	mov    0x14(%eax),%edx
80101306:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101309:	8b 45 0c             	mov    0xc(%ebp),%eax
8010130c:	01 c3                	add    %eax,%ebx
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 40 10             	mov    0x10(%eax),%eax
80101314:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101318:	89 54 24 08          	mov    %edx,0x8(%esp)
8010131c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101320:	89 04 24             	mov    %eax,(%esp)
80101323:	e8 c0 0c 00 00       	call   80101fe8 <writei>
80101328:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010132b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010132f:	7e 11                	jle    80101342 <filewrite+0xdb>
        f->off += r;
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010133a:	01 c2                	add    %eax,%edx
8010133c:	8b 45 08             	mov    0x8(%ebp),%eax
8010133f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101342:	8b 45 08             	mov    0x8(%ebp),%eax
80101345:	8b 40 10             	mov    0x10(%eax),%eax
80101348:	89 04 24             	mov    %eax,(%esp)
8010134b:	e8 75 07 00 00       	call   80101ac5 <iunlock>
      end_op();
80101350:	e8 e0 22 00 00       	call   80103635 <end_op>

      if(r < 0)
80101355:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101359:	79 02                	jns    8010135d <filewrite+0xf6>
        break;
8010135b:	eb 26                	jmp    80101383 <filewrite+0x11c>
      if(r != n1)
8010135d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101360:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101363:	74 0c                	je     80101371 <filewrite+0x10a>
        panic("short filewrite");
80101365:	c7 04 24 58 89 10 80 	movl   $0x80108958,(%esp)
8010136c:	e8 66 f2 ff ff       	call   801005d7 <panic>
      i += r;
80101371:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101374:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010137d:	0f 8c 4c ff ff ff    	jl     801012cf <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101386:	3b 45 10             	cmp    0x10(%ebp),%eax
80101389:	75 05                	jne    80101390 <filewrite+0x129>
8010138b:	8b 45 10             	mov    0x10(%ebp),%eax
8010138e:	eb 05                	jmp    80101395 <filewrite+0x12e>
80101390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101395:	eb 0c                	jmp    801013a3 <filewrite+0x13c>
  }
  panic("filewrite");
80101397:	c7 04 24 68 89 10 80 	movl   $0x80108968,(%esp)
8010139e:	e8 34 f2 ff ff       	call   801005d7 <panic>
}
801013a3:	83 c4 24             	add    $0x24,%esp
801013a6:	5b                   	pop    %ebx
801013a7:	5d                   	pop    %ebp
801013a8:	c3                   	ret    

801013a9 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013a9:	55                   	push   %ebp
801013aa:	89 e5                	mov    %esp,%ebp
801013ac:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801013af:	8b 45 08             	mov    0x8(%ebp),%eax
801013b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801013b9:	00 
801013ba:	89 04 24             	mov    %eax,(%esp)
801013bd:	e8 e4 ed ff ff       	call   801001a6 <bread>
801013c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c8:	83 c0 18             	add    $0x18,%eax
801013cb:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801013d2:	00 
801013d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801013d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801013da:	89 04 24             	mov    %eax,(%esp)
801013dd:	e8 8c 3f 00 00       	call   8010536e <memmove>
  brelse(bp);
801013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e5:	89 04 24             	mov    %eax,(%esp)
801013e8:	e8 2a ee ff ff       	call   80100217 <brelse>
}
801013ed:	c9                   	leave  
801013ee:	c3                   	ret    

801013ef <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013ef:	55                   	push   %ebp
801013f0:	89 e5                	mov    %esp,%ebp
801013f2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801013f8:	8b 45 08             	mov    0x8(%ebp),%eax
801013fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801013ff:	89 04 24             	mov    %eax,(%esp)
80101402:	e8 9f ed ff ff       	call   801001a6 <bread>
80101407:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010140a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010140d:	83 c0 18             	add    $0x18,%eax
80101410:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101417:	00 
80101418:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010141f:	00 
80101420:	89 04 24             	mov    %eax,(%esp)
80101423:	e8 77 3e 00 00       	call   8010529f <memset>
  log_write(bp);
80101428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142b:	89 04 24             	mov    %eax,(%esp)
8010142e:	e8 89 23 00 00       	call   801037bc <log_write>
  brelse(bp);
80101433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101436:	89 04 24             	mov    %eax,(%esp)
80101439:	e8 d9 ed ff ff       	call   80100217 <brelse>
}
8010143e:	c9                   	leave  
8010143f:	c3                   	ret    

80101440 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101440:	55                   	push   %ebp
80101441:	89 e5                	mov    %esp,%ebp
80101443:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101446:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010144d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101454:	e9 07 01 00 00       	jmp    80101560 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
80101459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010145c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101462:	85 c0                	test   %eax,%eax
80101464:	0f 48 c2             	cmovs  %edx,%eax
80101467:	c1 f8 0c             	sar    $0xc,%eax
8010146a:	89 c2                	mov    %eax,%edx
8010146c:	a1 18 1c 11 80       	mov    0x80111c18,%eax
80101471:	01 d0                	add    %edx,%eax
80101473:	89 44 24 04          	mov    %eax,0x4(%esp)
80101477:	8b 45 08             	mov    0x8(%ebp),%eax
8010147a:	89 04 24             	mov    %eax,(%esp)
8010147d:	e8 24 ed ff ff       	call   801001a6 <bread>
80101482:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101485:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010148c:	e9 9d 00 00 00       	jmp    8010152e <balloc+0xee>
      m = 1 << (bi % 8);
80101491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101494:	99                   	cltd   
80101495:	c1 ea 1d             	shr    $0x1d,%edx
80101498:	01 d0                	add    %edx,%eax
8010149a:	83 e0 07             	and    $0x7,%eax
8010149d:	29 d0                	sub    %edx,%eax
8010149f:	ba 01 00 00 00       	mov    $0x1,%edx
801014a4:	89 c1                	mov    %eax,%ecx
801014a6:	d3 e2                	shl    %cl,%edx
801014a8:	89 d0                	mov    %edx,%eax
801014aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b0:	8d 50 07             	lea    0x7(%eax),%edx
801014b3:	85 c0                	test   %eax,%eax
801014b5:	0f 48 c2             	cmovs  %edx,%eax
801014b8:	c1 f8 03             	sar    $0x3,%eax
801014bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014be:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801014c3:	0f b6 c0             	movzbl %al,%eax
801014c6:	23 45 e8             	and    -0x18(%ebp),%eax
801014c9:	85 c0                	test   %eax,%eax
801014cb:	75 5d                	jne    8010152a <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
801014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d0:	8d 50 07             	lea    0x7(%eax),%edx
801014d3:	85 c0                	test   %eax,%eax
801014d5:	0f 48 c2             	cmovs  %edx,%eax
801014d8:	c1 f8 03             	sar    $0x3,%eax
801014db:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014de:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014e3:	89 d1                	mov    %edx,%ecx
801014e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014e8:	09 ca                	or     %ecx,%edx
801014ea:	89 d1                	mov    %edx,%ecx
801014ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ef:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014f6:	89 04 24             	mov    %eax,(%esp)
801014f9:	e8 be 22 00 00       	call   801037bc <log_write>
        brelse(bp);
801014fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101501:	89 04 24             	mov    %eax,(%esp)
80101504:	e8 0e ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010150f:	01 c2                	add    %eax,%edx
80101511:	8b 45 08             	mov    0x8(%ebp),%eax
80101514:	89 54 24 04          	mov    %edx,0x4(%esp)
80101518:	89 04 24             	mov    %eax,(%esp)
8010151b:	e8 cf fe ff ff       	call   801013ef <bzero>
        return b + bi;
80101520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101523:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101526:	01 d0                	add    %edx,%eax
80101528:	eb 52                	jmp    8010157c <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010152a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010152e:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101535:	7f 17                	jg     8010154e <balloc+0x10e>
80101537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153d:	01 d0                	add    %edx,%eax
8010153f:	89 c2                	mov    %eax,%edx
80101541:	a1 00 1c 11 80       	mov    0x80111c00,%eax
80101546:	39 c2                	cmp    %eax,%edx
80101548:	0f 82 43 ff ff ff    	jb     80101491 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010154e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101551:	89 04 24             	mov    %eax,(%esp)
80101554:	e8 be ec ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101559:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101563:	a1 00 1c 11 80       	mov    0x80111c00,%eax
80101568:	39 c2                	cmp    %eax,%edx
8010156a:	0f 82 e9 fe ff ff    	jb     80101459 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101570:	c7 04 24 74 89 10 80 	movl   $0x80108974,(%esp)
80101577:	e8 5b f0 ff ff       	call   801005d7 <panic>
}
8010157c:	c9                   	leave  
8010157d:	c3                   	ret    

8010157e <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010157e:	55                   	push   %ebp
8010157f:	89 e5                	mov    %esp,%ebp
80101581:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101584:	c7 44 24 04 00 1c 11 	movl   $0x80111c00,0x4(%esp)
8010158b:	80 
8010158c:	8b 45 08             	mov    0x8(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 12 fe ff ff       	call   801013a9 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101597:	8b 45 0c             	mov    0xc(%ebp),%eax
8010159a:	c1 e8 0c             	shr    $0xc,%eax
8010159d:	89 c2                	mov    %eax,%edx
8010159f:	a1 18 1c 11 80       	mov    0x80111c18,%eax
801015a4:	01 c2                	add    %eax,%edx
801015a6:	8b 45 08             	mov    0x8(%ebp),%eax
801015a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801015ad:	89 04 24             	mov    %eax,(%esp)
801015b0:	e8 f1 eb ff ff       	call   801001a6 <bread>
801015b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801015bb:	25 ff 0f 00 00       	and    $0xfff,%eax
801015c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c6:	99                   	cltd   
801015c7:	c1 ea 1d             	shr    $0x1d,%edx
801015ca:	01 d0                	add    %edx,%eax
801015cc:	83 e0 07             	and    $0x7,%eax
801015cf:	29 d0                	sub    %edx,%eax
801015d1:	ba 01 00 00 00       	mov    $0x1,%edx
801015d6:	89 c1                	mov    %eax,%ecx
801015d8:	d3 e2                	shl    %cl,%edx
801015da:	89 d0                	mov    %edx,%eax
801015dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e2:	8d 50 07             	lea    0x7(%eax),%edx
801015e5:	85 c0                	test   %eax,%eax
801015e7:	0f 48 c2             	cmovs  %edx,%eax
801015ea:	c1 f8 03             	sar    $0x3,%eax
801015ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f0:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801015f5:	0f b6 c0             	movzbl %al,%eax
801015f8:	23 45 ec             	and    -0x14(%ebp),%eax
801015fb:	85 c0                	test   %eax,%eax
801015fd:	75 0c                	jne    8010160b <bfree+0x8d>
    panic("freeing free block");
801015ff:	c7 04 24 8a 89 10 80 	movl   $0x8010898a,(%esp)
80101606:	e8 cc ef ff ff       	call   801005d7 <panic>
  bp->data[bi/8] &= ~m;
8010160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160e:	8d 50 07             	lea    0x7(%eax),%edx
80101611:	85 c0                	test   %eax,%eax
80101613:	0f 48 c2             	cmovs  %edx,%eax
80101616:	c1 f8 03             	sar    $0x3,%eax
80101619:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101621:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101624:	f7 d1                	not    %ecx
80101626:	21 ca                	and    %ecx,%edx
80101628:	89 d1                	mov    %edx,%ecx
8010162a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101634:	89 04 24             	mov    %eax,(%esp)
80101637:	e8 80 21 00 00       	call   801037bc <log_write>
  brelse(bp);
8010163c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010163f:	89 04 24             	mov    %eax,(%esp)
80101642:	e8 d0 eb ff ff       	call   80100217 <brelse>
}
80101647:	c9                   	leave  
80101648:	c3                   	ret    

80101649 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101649:	55                   	push   %ebp
8010164a:	89 e5                	mov    %esp,%ebp
8010164c:	57                   	push   %edi
8010164d:	56                   	push   %esi
8010164e:	53                   	push   %ebx
8010164f:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
80101652:	c7 44 24 04 9d 89 10 	movl   $0x8010899d,0x4(%esp)
80101659:	80 
8010165a:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101661:	e8 c4 39 00 00       	call   8010502a <initlock>
  readsb(dev, &sb);
80101666:	c7 44 24 04 00 1c 11 	movl   $0x80111c00,0x4(%esp)
8010166d:	80 
8010166e:	8b 45 08             	mov    0x8(%ebp),%eax
80101671:	89 04 24             	mov    %eax,(%esp)
80101674:	e8 30 fd ff ff       	call   801013a9 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101679:	a1 18 1c 11 80       	mov    0x80111c18,%eax
8010167e:	8b 3d 14 1c 11 80    	mov    0x80111c14,%edi
80101684:	8b 35 10 1c 11 80    	mov    0x80111c10,%esi
8010168a:	8b 1d 0c 1c 11 80    	mov    0x80111c0c,%ebx
80101690:	8b 0d 08 1c 11 80    	mov    0x80111c08,%ecx
80101696:	8b 15 04 1c 11 80    	mov    0x80111c04,%edx
8010169c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010169f:	8b 15 00 1c 11 80    	mov    0x80111c00,%edx
801016a5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801016a9:	89 7c 24 18          	mov    %edi,0x18(%esp)
801016ad:	89 74 24 14          	mov    %esi,0x14(%esp)
801016b1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801016b5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801016b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016bc:	89 44 24 08          	mov    %eax,0x8(%esp)
801016c0:	89 d0                	mov    %edx,%eax
801016c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801016c6:	c7 04 24 a4 89 10 80 	movl   $0x801089a4,(%esp)
801016cd:	e8 31 ed ff ff       	call   80100403 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016d2:	83 c4 3c             	add    $0x3c,%esp
801016d5:	5b                   	pop    %ebx
801016d6:	5e                   	pop    %esi
801016d7:	5f                   	pop    %edi
801016d8:	5d                   	pop    %ebp
801016d9:	c3                   	ret    

801016da <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016da:	55                   	push   %ebp
801016db:	89 e5                	mov    %esp,%ebp
801016dd:	83 ec 28             	sub    $0x28,%esp
801016e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e3:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016e7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016ee:	e9 9e 00 00 00       	jmp    80101791 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f6:	c1 e8 03             	shr    $0x3,%eax
801016f9:	89 c2                	mov    %eax,%edx
801016fb:	a1 14 1c 11 80       	mov    0x80111c14,%eax
80101700:	01 d0                	add    %edx,%eax
80101702:	89 44 24 04          	mov    %eax,0x4(%esp)
80101706:	8b 45 08             	mov    0x8(%ebp),%eax
80101709:	89 04 24             	mov    %eax,(%esp)
8010170c:	e8 95 ea ff ff       	call   801001a6 <bread>
80101711:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101717:	8d 50 18             	lea    0x18(%eax),%edx
8010171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171d:	83 e0 07             	and    $0x7,%eax
80101720:	c1 e0 06             	shl    $0x6,%eax
80101723:	01 d0                	add    %edx,%eax
80101725:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101728:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010172b:	0f b7 00             	movzwl (%eax),%eax
8010172e:	66 85 c0             	test   %ax,%ax
80101731:	75 4f                	jne    80101782 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101733:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010173a:	00 
8010173b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101742:	00 
80101743:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101746:	89 04 24             	mov    %eax,(%esp)
80101749:	e8 51 3b 00 00       	call   8010529f <memset>
      dip->type = type;
8010174e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101751:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101755:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175b:	89 04 24             	mov    %eax,(%esp)
8010175e:	e8 59 20 00 00       	call   801037bc <log_write>
      brelse(bp);
80101763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101766:	89 04 24             	mov    %eax,(%esp)
80101769:	e8 a9 ea ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010176e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101771:	89 44 24 04          	mov    %eax,0x4(%esp)
80101775:	8b 45 08             	mov    0x8(%ebp),%eax
80101778:	89 04 24             	mov    %eax,(%esp)
8010177b:	e8 ed 00 00 00       	call   8010186d <iget>
80101780:	eb 2b                	jmp    801017ad <ialloc+0xd3>
    }
    brelse(bp);
80101782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101785:	89 04 24             	mov    %eax,(%esp)
80101788:	e8 8a ea ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010178d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101791:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101794:	a1 08 1c 11 80       	mov    0x80111c08,%eax
80101799:	39 c2                	cmp    %eax,%edx
8010179b:	0f 82 52 ff ff ff    	jb     801016f3 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801017a1:	c7 04 24 f7 89 10 80 	movl   $0x801089f7,(%esp)
801017a8:	e8 2a ee ff ff       	call   801005d7 <panic>
}
801017ad:	c9                   	leave  
801017ae:	c3                   	ret    

801017af <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801017af:	55                   	push   %ebp
801017b0:	89 e5                	mov    %esp,%ebp
801017b2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017b5:	8b 45 08             	mov    0x8(%ebp),%eax
801017b8:	8b 40 04             	mov    0x4(%eax),%eax
801017bb:	c1 e8 03             	shr    $0x3,%eax
801017be:	89 c2                	mov    %eax,%edx
801017c0:	a1 14 1c 11 80       	mov    0x80111c14,%eax
801017c5:	01 c2                	add    %eax,%edx
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	8b 00                	mov    (%eax),%eax
801017cc:	89 54 24 04          	mov    %edx,0x4(%esp)
801017d0:	89 04 24             	mov    %eax,(%esp)
801017d3:	e8 ce e9 ff ff       	call   801001a6 <bread>
801017d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017de:	8d 50 18             	lea    0x18(%eax),%edx
801017e1:	8b 45 08             	mov    0x8(%ebp),%eax
801017e4:	8b 40 04             	mov    0x4(%eax),%eax
801017e7:	83 e0 07             	and    $0x7,%eax
801017ea:	c1 e0 06             	shl    $0x6,%eax
801017ed:	01 d0                	add    %edx,%eax
801017ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017f2:	8b 45 08             	mov    0x8(%ebp),%eax
801017f5:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fc:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101802:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101809:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010180d:	8b 45 08             	mov    0x8(%ebp),%eax
80101810:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101814:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101817:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101822:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101825:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101829:	8b 45 08             	mov    0x8(%ebp),%eax
8010182c:	8b 50 18             	mov    0x18(%eax),%edx
8010182f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101832:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101835:	8b 45 08             	mov    0x8(%ebp),%eax
80101838:	8d 50 1c             	lea    0x1c(%eax),%edx
8010183b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183e:	83 c0 0c             	add    $0xc,%eax
80101841:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101848:	00 
80101849:	89 54 24 04          	mov    %edx,0x4(%esp)
8010184d:	89 04 24             	mov    %eax,(%esp)
80101850:	e8 19 3b 00 00       	call   8010536e <memmove>
  log_write(bp);
80101855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101858:	89 04 24             	mov    %eax,(%esp)
8010185b:	e8 5c 1f 00 00       	call   801037bc <log_write>
  brelse(bp);
80101860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101863:	89 04 24             	mov    %eax,(%esp)
80101866:	e8 ac e9 ff ff       	call   80100217 <brelse>
}
8010186b:	c9                   	leave  
8010186c:	c3                   	ret    

8010186d <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010186d:	55                   	push   %ebp
8010186e:	89 e5                	mov    %esp,%ebp
80101870:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101873:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
8010187a:	e8 cc 37 00 00       	call   8010504b <acquire>

  // Is the inode already cached?
  empty = 0;
8010187f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101886:	c7 45 f4 54 1c 11 80 	movl   $0x80111c54,-0xc(%ebp)
8010188d:	eb 59                	jmp    801018e8 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101892:	8b 40 08             	mov    0x8(%eax),%eax
80101895:	85 c0                	test   %eax,%eax
80101897:	7e 35                	jle    801018ce <iget+0x61>
80101899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189c:	8b 00                	mov    (%eax),%eax
8010189e:	3b 45 08             	cmp    0x8(%ebp),%eax
801018a1:	75 2b                	jne    801018ce <iget+0x61>
801018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a6:	8b 40 04             	mov    0x4(%eax),%eax
801018a9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801018ac:	75 20                	jne    801018ce <iget+0x61>
      ip->ref++;
801018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b1:	8b 40 08             	mov    0x8(%eax),%eax
801018b4:	8d 50 01             	lea    0x1(%eax),%edx
801018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ba:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018bd:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
801018c4:	e8 e4 37 00 00       	call   801050ad <release>
      return ip;
801018c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cc:	eb 6f                	jmp    8010193d <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018d2:	75 10                	jne    801018e4 <iget+0x77>
801018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d7:	8b 40 08             	mov    0x8(%eax),%eax
801018da:	85 c0                	test   %eax,%eax
801018dc:	75 06                	jne    801018e4 <iget+0x77>
      empty = ip;
801018de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018e4:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018e8:	81 7d f4 f4 2b 11 80 	cmpl   $0x80112bf4,-0xc(%ebp)
801018ef:	72 9e                	jb     8010188f <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018f5:	75 0c                	jne    80101903 <iget+0x96>
    panic("iget: no inodes");
801018f7:	c7 04 24 09 8a 10 80 	movl   $0x80108a09,(%esp)
801018fe:	e8 d4 ec ff ff       	call   801005d7 <panic>

  ip = empty;
80101903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101906:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190c:	8b 55 08             	mov    0x8(%ebp),%edx
8010190f:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101914:	8b 55 0c             	mov    0xc(%ebp),%edx
80101917:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010191a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010192e:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101935:	e8 73 37 00 00       	call   801050ad <release>

  return ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010193d:	c9                   	leave  
8010193e:	c3                   	ret    

8010193f <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010193f:	55                   	push   %ebp
80101940:	89 e5                	mov    %esp,%ebp
80101942:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101945:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
8010194c:	e8 fa 36 00 00       	call   8010504b <acquire>
  ip->ref++;
80101951:	8b 45 08             	mov    0x8(%ebp),%eax
80101954:	8b 40 08             	mov    0x8(%eax),%eax
80101957:	8d 50 01             	lea    0x1(%eax),%edx
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101960:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101967:	e8 41 37 00 00       	call   801050ad <release>
  return ip;
8010196c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010196f:	c9                   	leave  
80101970:	c3                   	ret    

80101971 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101971:	55                   	push   %ebp
80101972:	89 e5                	mov    %esp,%ebp
80101974:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010197b:	74 0a                	je     80101987 <ilock+0x16>
8010197d:	8b 45 08             	mov    0x8(%ebp),%eax
80101980:	8b 40 08             	mov    0x8(%eax),%eax
80101983:	85 c0                	test   %eax,%eax
80101985:	7f 0c                	jg     80101993 <ilock+0x22>
    panic("ilock");
80101987:	c7 04 24 19 8a 10 80 	movl   $0x80108a19,(%esp)
8010198e:	e8 44 ec ff ff       	call   801005d7 <panic>

  acquire(&icache.lock);
80101993:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
8010199a:	e8 ac 36 00 00       	call   8010504b <acquire>
  while(ip->flags & I_BUSY)
8010199f:	eb 13                	jmp    801019b4 <ilock+0x43>
    sleep(ip, &icache.lock);
801019a1:	c7 44 24 04 20 1c 11 	movl   $0x80111c20,0x4(%esp)
801019a8:	80 
801019a9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ac:	89 04 24             	mov    %eax,(%esp)
801019af:	e8 c3 33 00 00       	call   80104d77 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019b4:	8b 45 08             	mov    0x8(%ebp),%eax
801019b7:	8b 40 0c             	mov    0xc(%eax),%eax
801019ba:	83 e0 01             	and    $0x1,%eax
801019bd:	85 c0                	test   %eax,%eax
801019bf:	75 e0                	jne    801019a1 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	8b 40 0c             	mov    0xc(%eax),%eax
801019c7:	83 c8 01             	or     $0x1,%eax
801019ca:	89 c2                	mov    %eax,%edx
801019cc:	8b 45 08             	mov    0x8(%ebp),%eax
801019cf:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019d2:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
801019d9:	e8 cf 36 00 00       	call   801050ad <release>

  if(!(ip->flags & I_VALID)){
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	8b 40 0c             	mov    0xc(%eax),%eax
801019e4:	83 e0 02             	and    $0x2,%eax
801019e7:	85 c0                	test   %eax,%eax
801019e9:	0f 85 d4 00 00 00    	jne    80101ac3 <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019ef:	8b 45 08             	mov    0x8(%ebp),%eax
801019f2:	8b 40 04             	mov    0x4(%eax),%eax
801019f5:	c1 e8 03             	shr    $0x3,%eax
801019f8:	89 c2                	mov    %eax,%edx
801019fa:	a1 14 1c 11 80       	mov    0x80111c14,%eax
801019ff:	01 c2                	add    %eax,%edx
80101a01:	8b 45 08             	mov    0x8(%ebp),%eax
80101a04:	8b 00                	mov    (%eax),%eax
80101a06:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a0a:	89 04 24             	mov    %eax,(%esp)
80101a0d:	e8 94 e7 ff ff       	call   801001a6 <bread>
80101a12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a18:	8d 50 18             	lea    0x18(%eax),%edx
80101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1e:	8b 40 04             	mov    0x4(%eax),%eax
80101a21:	83 e0 07             	and    $0x7,%eax
80101a24:	c1 e0 06             	shl    $0x6,%eax
80101a27:	01 d0                	add    %edx,%eax
80101a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a2f:	0f b7 10             	movzwl (%eax),%edx
80101a32:	8b 45 08             	mov    0x8(%ebp),%eax
80101a35:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a51:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a58:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a66:	8b 50 08             	mov    0x8(%eax),%edx
80101a69:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6c:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a72:	8d 50 0c             	lea    0xc(%eax),%edx
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	83 c0 1c             	add    $0x1c,%eax
80101a7b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a82:	00 
80101a83:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a87:	89 04 24             	mov    %eax,(%esp)
80101a8a:	e8 df 38 00 00       	call   8010536e <memmove>
    brelse(bp);
80101a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a92:	89 04 24             	mov    %eax,(%esp)
80101a95:	e8 7d e7 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9d:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa0:	83 c8 02             	or     $0x2,%eax
80101aa3:	89 c2                	mov    %eax,%edx
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab2:	66 85 c0             	test   %ax,%ax
80101ab5:	75 0c                	jne    80101ac3 <ilock+0x152>
      panic("ilock: no type");
80101ab7:	c7 04 24 1f 8a 10 80 	movl   $0x80108a1f,(%esp)
80101abe:	e8 14 eb ff ff       	call   801005d7 <panic>
  }
}
80101ac3:	c9                   	leave  
80101ac4:	c3                   	ret    

80101ac5 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac5:	55                   	push   %ebp
80101ac6:	89 e5                	mov    %esp,%ebp
80101ac8:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101acb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101acf:	74 17                	je     80101ae8 <iunlock+0x23>
80101ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad4:	8b 40 0c             	mov    0xc(%eax),%eax
80101ad7:	83 e0 01             	and    $0x1,%eax
80101ada:	85 c0                	test   %eax,%eax
80101adc:	74 0a                	je     80101ae8 <iunlock+0x23>
80101ade:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae1:	8b 40 08             	mov    0x8(%eax),%eax
80101ae4:	85 c0                	test   %eax,%eax
80101ae6:	7f 0c                	jg     80101af4 <iunlock+0x2f>
    panic("iunlock");
80101ae8:	c7 04 24 2e 8a 10 80 	movl   $0x80108a2e,(%esp)
80101aef:	e8 e3 ea ff ff       	call   801005d7 <panic>

  acquire(&icache.lock);
80101af4:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101afb:	e8 4b 35 00 00       	call   8010504b <acquire>
  ip->flags &= ~I_BUSY;
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 0c             	mov    0xc(%eax),%eax
80101b06:	83 e0 fe             	and    $0xfffffffe,%eax
80101b09:	89 c2                	mov    %eax,%edx
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	89 04 24             	mov    %eax,(%esp)
80101b17:	e8 34 33 00 00       	call   80104e50 <wakeup>
  release(&icache.lock);
80101b1c:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101b23:	e8 85 35 00 00       	call   801050ad <release>
}
80101b28:	c9                   	leave  
80101b29:	c3                   	ret    

80101b2a <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b2a:	55                   	push   %ebp
80101b2b:	89 e5                	mov    %esp,%ebp
80101b2d:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b30:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101b37:	e8 0f 35 00 00       	call   8010504b <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3f:	8b 40 08             	mov    0x8(%eax),%eax
80101b42:	83 f8 01             	cmp    $0x1,%eax
80101b45:	0f 85 93 00 00 00    	jne    80101bde <iput+0xb4>
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	8b 40 0c             	mov    0xc(%eax),%eax
80101b51:	83 e0 02             	and    $0x2,%eax
80101b54:	85 c0                	test   %eax,%eax
80101b56:	0f 84 82 00 00 00    	je     80101bde <iput+0xb4>
80101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b63:	66 85 c0             	test   %ax,%ax
80101b66:	75 76                	jne    80101bde <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b68:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b6e:	83 e0 01             	and    $0x1,%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 0c                	je     80101b81 <iput+0x57>
      panic("iput busy");
80101b75:	c7 04 24 36 8a 10 80 	movl   $0x80108a36,(%esp)
80101b7c:	e8 56 ea ff ff       	call   801005d7 <panic>
    ip->flags |= I_BUSY;
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	8b 40 0c             	mov    0xc(%eax),%eax
80101b87:	83 c8 01             	or     $0x1,%eax
80101b8a:	89 c2                	mov    %eax,%edx
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b92:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101b99:	e8 0f 35 00 00       	call   801050ad <release>
    itrunc(ip);
80101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba1:	89 04 24             	mov    %eax,(%esp)
80101ba4:	e8 7d 01 00 00       	call   80101d26 <itrunc>
    ip->type = 0;
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb5:	89 04 24             	mov    %eax,(%esp)
80101bb8:	e8 f2 fb ff ff       	call   801017af <iupdate>
    acquire(&icache.lock);
80101bbd:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101bc4:	e8 82 34 00 00       	call   8010504b <acquire>
    ip->flags = 0;
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd6:	89 04 24             	mov    %eax,(%esp)
80101bd9:	e8 72 32 00 00       	call   80104e50 <wakeup>
  }
  ip->ref--;
80101bde:	8b 45 08             	mov    0x8(%ebp),%eax
80101be1:	8b 40 08             	mov    0x8(%eax),%eax
80101be4:	8d 50 ff             	lea    -0x1(%eax),%edx
80101be7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bea:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bed:	c7 04 24 20 1c 11 80 	movl   $0x80111c20,(%esp)
80101bf4:	e8 b4 34 00 00       	call   801050ad <release>
}
80101bf9:	c9                   	leave  
80101bfa:	c3                   	ret    

80101bfb <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101bfb:	55                   	push   %ebp
80101bfc:	89 e5                	mov    %esp,%ebp
80101bfe:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	89 04 24             	mov    %eax,(%esp)
80101c07:	e8 b9 fe ff ff       	call   80101ac5 <iunlock>
  iput(ip);
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	89 04 24             	mov    %eax,(%esp)
80101c12:	e8 13 ff ff ff       	call   80101b2a <iput>
}
80101c17:	c9                   	leave  
80101c18:	c3                   	ret    

80101c19 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c19:	55                   	push   %ebp
80101c1a:	89 e5                	mov    %esp,%ebp
80101c1c:	53                   	push   %ebx
80101c1d:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c20:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c24:	77 3e                	ja     80101c64 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c2c:	83 c2 04             	add    $0x4,%edx
80101c2f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c36:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c3a:	75 20                	jne    80101c5c <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3f:	8b 00                	mov    (%eax),%eax
80101c41:	89 04 24             	mov    %eax,(%esp)
80101c44:	e8 f7 f7 ff ff       	call   80101440 <balloc>
80101c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c58:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5f:	e9 bc 00 00 00       	jmp    80101d20 <bmap+0x107>
  }
  bn -= NDIRECT;
80101c64:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c68:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c6c:	0f 87 a2 00 00 00    	ja     80101d14 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c7f:	75 19                	jne    80101c9a <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c81:	8b 45 08             	mov    0x8(%ebp),%eax
80101c84:	8b 00                	mov    (%eax),%eax
80101c86:	89 04 24             	mov    %eax,(%esp)
80101c89:	e8 b2 f7 ff ff       	call   80101440 <balloc>
80101c8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c91:	8b 45 08             	mov    0x8(%ebp),%eax
80101c94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c97:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9d:	8b 00                	mov    (%eax),%eax
80101c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ca6:	89 04 24             	mov    %eax,(%esp)
80101ca9:	e8 f8 e4 ff ff       	call   801001a6 <bread>
80101cae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb4:	83 c0 18             	add    $0x18,%eax
80101cb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cba:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cc7:	01 d0                	add    %edx,%eax
80101cc9:	8b 00                	mov    (%eax),%eax
80101ccb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cd2:	75 30                	jne    80101d04 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cd7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cde:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce7:	8b 00                	mov    (%eax),%eax
80101ce9:	89 04 24             	mov    %eax,(%esp)
80101cec:	e8 4f f7 ff ff       	call   80101440 <balloc>
80101cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf7:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cfc:	89 04 24             	mov    %eax,(%esp)
80101cff:	e8 b8 1a 00 00       	call   801037bc <log_write>
    }
    brelse(bp);
80101d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d07:	89 04 24             	mov    %eax,(%esp)
80101d0a:	e8 08 e5 ff ff       	call   80100217 <brelse>
    return addr;
80101d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d12:	eb 0c                	jmp    80101d20 <bmap+0x107>
  }

  panic("bmap: out of range");
80101d14:	c7 04 24 40 8a 10 80 	movl   $0x80108a40,(%esp)
80101d1b:	e8 b7 e8 ff ff       	call   801005d7 <panic>
}
80101d20:	83 c4 24             	add    $0x24,%esp
80101d23:	5b                   	pop    %ebx
80101d24:	5d                   	pop    %ebp
80101d25:	c3                   	ret    

80101d26 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d26:	55                   	push   %ebp
80101d27:	89 e5                	mov    %esp,%ebp
80101d29:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d33:	eb 44                	jmp    80101d79 <itrunc+0x53>
    if(ip->addrs[i]){
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3b:	83 c2 04             	add    $0x4,%edx
80101d3e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d42:	85 c0                	test   %eax,%eax
80101d44:	74 2f                	je     80101d75 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d4c:	83 c2 04             	add    $0x4,%edx
80101d4f:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101d53:	8b 45 08             	mov    0x8(%ebp),%eax
80101d56:	8b 00                	mov    (%eax),%eax
80101d58:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d5c:	89 04 24             	mov    %eax,(%esp)
80101d5f:	e8 1a f8 ff ff       	call   8010157e <bfree>
      ip->addrs[i] = 0;
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6a:	83 c2 04             	add    $0x4,%edx
80101d6d:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d74:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d79:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d7d:	7e b6                	jle    80101d35 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d85:	85 c0                	test   %eax,%eax
80101d87:	0f 84 9b 00 00 00    	je     80101e28 <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d90:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d93:	8b 45 08             	mov    0x8(%ebp),%eax
80101d96:	8b 00                	mov    (%eax),%eax
80101d98:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d9c:	89 04 24             	mov    %eax,(%esp)
80101d9f:	e8 02 e4 ff ff       	call   801001a6 <bread>
80101da4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101daa:	83 c0 18             	add    $0x18,%eax
80101dad:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101db0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101db7:	eb 3b                	jmp    80101df4 <itrunc+0xce>
      if(a[j])
80101db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dc6:	01 d0                	add    %edx,%eax
80101dc8:	8b 00                	mov    (%eax),%eax
80101dca:	85 c0                	test   %eax,%eax
80101dcc:	74 22                	je     80101df0 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ddb:	01 d0                	add    %edx,%eax
80101ddd:	8b 10                	mov    (%eax),%edx
80101ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80101de2:	8b 00                	mov    (%eax),%eax
80101de4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101de8:	89 04 24             	mov    %eax,(%esp)
80101deb:	e8 8e f7 ff ff       	call   8010157e <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101df0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101df7:	83 f8 7f             	cmp    $0x7f,%eax
80101dfa:	76 bd                	jbe    80101db9 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101dfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dff:	89 04 24             	mov    %eax,(%esp)
80101e02:	e8 10 e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e07:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0a:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	8b 00                	mov    (%eax),%eax
80101e12:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e16:	89 04 24             	mov    %eax,(%esp)
80101e19:	e8 60 f7 ff ff       	call   8010157e <bfree>
    ip->addrs[NDIRECT] = 0;
80101e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e21:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e28:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2b:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e32:	8b 45 08             	mov    0x8(%ebp),%eax
80101e35:	89 04 24             	mov    %eax,(%esp)
80101e38:	e8 72 f9 ff ff       	call   801017af <iupdate>
}
80101e3d:	c9                   	leave  
80101e3e:	c3                   	ret    

80101e3f <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e3f:	55                   	push   %ebp
80101e40:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e42:	8b 45 08             	mov    0x8(%ebp),%eax
80101e45:	8b 00                	mov    (%eax),%eax
80101e47:	89 c2                	mov    %eax,%edx
80101e49:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e4c:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e52:	8b 50 04             	mov    0x4(%eax),%edx
80101e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e58:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e62:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e65:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e72:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e76:	8b 45 08             	mov    0x8(%ebp),%eax
80101e79:	8b 50 18             	mov    0x18(%eax),%edx
80101e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e7f:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e82:	5d                   	pop    %ebp
80101e83:	c3                   	ret    

80101e84 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e84:	55                   	push   %ebp
80101e85:	89 e5                	mov    %esp,%ebp
80101e87:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e91:	66 83 f8 03          	cmp    $0x3,%ax
80101e95:	75 60                	jne    80101ef7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e97:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e9e:	66 85 c0             	test   %ax,%ax
80101ea1:	78 20                	js     80101ec3 <readi+0x3f>
80101ea3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eaa:	66 83 f8 09          	cmp    $0x9,%ax
80101eae:	7f 13                	jg     80101ec3 <readi+0x3f>
80101eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eb7:	98                   	cwtl   
80101eb8:	8b 04 c5 a0 1b 11 80 	mov    -0x7feee460(,%eax,8),%eax
80101ebf:	85 c0                	test   %eax,%eax
80101ec1:	75 0a                	jne    80101ecd <readi+0x49>
      return -1;
80101ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ec8:	e9 19 01 00 00       	jmp    80101fe6 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ed4:	98                   	cwtl   
80101ed5:	8b 04 c5 a0 1b 11 80 	mov    -0x7feee460(,%eax,8),%eax
80101edc:	8b 55 14             	mov    0x14(%ebp),%edx
80101edf:	89 54 24 08          	mov    %edx,0x8(%esp)
80101ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ee6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eea:	8b 55 08             	mov    0x8(%ebp),%edx
80101eed:	89 14 24             	mov    %edx,(%esp)
80101ef0:	ff d0                	call   *%eax
80101ef2:	e9 ef 00 00 00       	jmp    80101fe6 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 40 18             	mov    0x18(%eax),%eax
80101efd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f00:	72 0d                	jb     80101f0f <readi+0x8b>
80101f02:	8b 45 14             	mov    0x14(%ebp),%eax
80101f05:	8b 55 10             	mov    0x10(%ebp),%edx
80101f08:	01 d0                	add    %edx,%eax
80101f0a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f0d:	73 0a                	jae    80101f19 <readi+0x95>
    return -1;
80101f0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f14:	e9 cd 00 00 00       	jmp    80101fe6 <readi+0x162>
  if(off + n > ip->size)
80101f19:	8b 45 14             	mov    0x14(%ebp),%eax
80101f1c:	8b 55 10             	mov    0x10(%ebp),%edx
80101f1f:	01 c2                	add    %eax,%edx
80101f21:	8b 45 08             	mov    0x8(%ebp),%eax
80101f24:	8b 40 18             	mov    0x18(%eax),%eax
80101f27:	39 c2                	cmp    %eax,%edx
80101f29:	76 0c                	jbe    80101f37 <readi+0xb3>
    n = ip->size - off;
80101f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2e:	8b 40 18             	mov    0x18(%eax),%eax
80101f31:	2b 45 10             	sub    0x10(%ebp),%eax
80101f34:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f3e:	e9 94 00 00 00       	jmp    80101fd7 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f43:	8b 45 10             	mov    0x10(%ebp),%eax
80101f46:	c1 e8 09             	shr    $0x9,%eax
80101f49:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	89 04 24             	mov    %eax,(%esp)
80101f53:	e8 c1 fc ff ff       	call   80101c19 <bmap>
80101f58:	8b 55 08             	mov    0x8(%ebp),%edx
80101f5b:	8b 12                	mov    (%edx),%edx
80101f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f61:	89 14 24             	mov    %edx,(%esp)
80101f64:	e8 3d e2 ff ff       	call   801001a6 <bread>
80101f69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f6c:	8b 45 10             	mov    0x10(%ebp),%eax
80101f6f:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f74:	89 c2                	mov    %eax,%edx
80101f76:	b8 00 02 00 00       	mov    $0x200,%eax
80101f7b:	29 d0                	sub    %edx,%eax
80101f7d:	89 c2                	mov    %eax,%edx
80101f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f82:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101f85:	29 c1                	sub    %eax,%ecx
80101f87:	89 c8                	mov    %ecx,%eax
80101f89:	39 c2                	cmp    %eax,%edx
80101f8b:	0f 46 c2             	cmovbe %edx,%eax
80101f8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f99:	8d 50 10             	lea    0x10(%eax),%edx
80101f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f9f:	01 d0                	add    %edx,%eax
80101fa1:	8d 50 08             	lea    0x8(%eax),%edx
80101fa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fab:	89 54 24 04          	mov    %edx,0x4(%esp)
80101faf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb2:	89 04 24             	mov    %eax,(%esp)
80101fb5:	e8 b4 33 00 00       	call   8010536e <memmove>
    brelse(bp);
80101fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fbd:	89 04 24             	mov    %eax,(%esp)
80101fc0:	e8 52 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fc8:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fce:	01 45 10             	add    %eax,0x10(%ebp)
80101fd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fd4:	01 45 0c             	add    %eax,0xc(%ebp)
80101fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fda:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fdd:	0f 82 60 ff ff ff    	jb     80101f43 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fe3:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fe6:	c9                   	leave  
80101fe7:	c3                   	ret    

80101fe8 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fe8:	55                   	push   %ebp
80101fe9:	89 e5                	mov    %esp,%ebp
80101feb:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fee:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ff5:	66 83 f8 03          	cmp    $0x3,%ax
80101ff9:	75 60                	jne    8010205b <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffe:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102002:	66 85 c0             	test   %ax,%ax
80102005:	78 20                	js     80102027 <writei+0x3f>
80102007:	8b 45 08             	mov    0x8(%ebp),%eax
8010200a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010200e:	66 83 f8 09          	cmp    $0x9,%ax
80102012:	7f 13                	jg     80102027 <writei+0x3f>
80102014:	8b 45 08             	mov    0x8(%ebp),%eax
80102017:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010201b:	98                   	cwtl   
8010201c:	8b 04 c5 a4 1b 11 80 	mov    -0x7feee45c(,%eax,8),%eax
80102023:	85 c0                	test   %eax,%eax
80102025:	75 0a                	jne    80102031 <writei+0x49>
      return -1;
80102027:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010202c:	e9 44 01 00 00       	jmp    80102175 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102038:	98                   	cwtl   
80102039:	8b 04 c5 a4 1b 11 80 	mov    -0x7feee45c(,%eax,8),%eax
80102040:	8b 55 14             	mov    0x14(%ebp),%edx
80102043:	89 54 24 08          	mov    %edx,0x8(%esp)
80102047:	8b 55 0c             	mov    0xc(%ebp),%edx
8010204a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010204e:	8b 55 08             	mov    0x8(%ebp),%edx
80102051:	89 14 24             	mov    %edx,(%esp)
80102054:	ff d0                	call   *%eax
80102056:	e9 1a 01 00 00       	jmp    80102175 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	8b 40 18             	mov    0x18(%eax),%eax
80102061:	3b 45 10             	cmp    0x10(%ebp),%eax
80102064:	72 0d                	jb     80102073 <writei+0x8b>
80102066:	8b 45 14             	mov    0x14(%ebp),%eax
80102069:	8b 55 10             	mov    0x10(%ebp),%edx
8010206c:	01 d0                	add    %edx,%eax
8010206e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102071:	73 0a                	jae    8010207d <writei+0x95>
    return -1;
80102073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102078:	e9 f8 00 00 00       	jmp    80102175 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
8010207d:	8b 45 14             	mov    0x14(%ebp),%eax
80102080:	8b 55 10             	mov    0x10(%ebp),%edx
80102083:	01 d0                	add    %edx,%eax
80102085:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010208a:	76 0a                	jbe    80102096 <writei+0xae>
    return -1;
8010208c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102091:	e9 df 00 00 00       	jmp    80102175 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102096:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010209d:	e9 9f 00 00 00       	jmp    80102141 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020a2:	8b 45 10             	mov    0x10(%ebp),%eax
801020a5:	c1 e8 09             	shr    $0x9,%eax
801020a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ac:	8b 45 08             	mov    0x8(%ebp),%eax
801020af:	89 04 24             	mov    %eax,(%esp)
801020b2:	e8 62 fb ff ff       	call   80101c19 <bmap>
801020b7:	8b 55 08             	mov    0x8(%ebp),%edx
801020ba:	8b 12                	mov    (%edx),%edx
801020bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801020c0:	89 14 24             	mov    %edx,(%esp)
801020c3:	e8 de e0 ff ff       	call   801001a6 <bread>
801020c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020cb:	8b 45 10             	mov    0x10(%ebp),%eax
801020ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d3:	89 c2                	mov    %eax,%edx
801020d5:	b8 00 02 00 00       	mov    $0x200,%eax
801020da:	29 d0                	sub    %edx,%eax
801020dc:	89 c2                	mov    %eax,%edx
801020de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020e1:	8b 4d 14             	mov    0x14(%ebp),%ecx
801020e4:	29 c1                	sub    %eax,%ecx
801020e6:	89 c8                	mov    %ecx,%eax
801020e8:	39 c2                	cmp    %eax,%edx
801020ea:	0f 46 c2             	cmovbe %edx,%eax
801020ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020f0:	8b 45 10             	mov    0x10(%ebp),%eax
801020f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801020f8:	8d 50 10             	lea    0x10(%eax),%edx
801020fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020fe:	01 d0                	add    %edx,%eax
80102100:	8d 50 08             	lea    0x8(%eax),%edx
80102103:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102106:	89 44 24 08          	mov    %eax,0x8(%esp)
8010210a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010210d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102111:	89 14 24             	mov    %edx,(%esp)
80102114:	e8 55 32 00 00       	call   8010536e <memmove>
    log_write(bp);
80102119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010211c:	89 04 24             	mov    %eax,(%esp)
8010211f:	e8 98 16 00 00       	call   801037bc <log_write>
    brelse(bp);
80102124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102127:	89 04 24             	mov    %eax,(%esp)
8010212a:	e8 e8 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010212f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102132:	01 45 f4             	add    %eax,-0xc(%ebp)
80102135:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102138:	01 45 10             	add    %eax,0x10(%ebp)
8010213b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010213e:	01 45 0c             	add    %eax,0xc(%ebp)
80102141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102144:	3b 45 14             	cmp    0x14(%ebp),%eax
80102147:	0f 82 55 ff ff ff    	jb     801020a2 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010214d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102151:	74 1f                	je     80102172 <writei+0x18a>
80102153:	8b 45 08             	mov    0x8(%ebp),%eax
80102156:	8b 40 18             	mov    0x18(%eax),%eax
80102159:	3b 45 10             	cmp    0x10(%ebp),%eax
8010215c:	73 14                	jae    80102172 <writei+0x18a>
    ip->size = off;
8010215e:	8b 45 08             	mov    0x8(%ebp),%eax
80102161:	8b 55 10             	mov    0x10(%ebp),%edx
80102164:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102167:	8b 45 08             	mov    0x8(%ebp),%eax
8010216a:	89 04 24             	mov    %eax,(%esp)
8010216d:	e8 3d f6 ff ff       	call   801017af <iupdate>
  }
  return n;
80102172:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102175:	c9                   	leave  
80102176:	c3                   	ret    

80102177 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102177:	55                   	push   %ebp
80102178:	89 e5                	mov    %esp,%ebp
8010217a:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010217d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102184:	00 
80102185:	8b 45 0c             	mov    0xc(%ebp),%eax
80102188:	89 44 24 04          	mov    %eax,0x4(%esp)
8010218c:	8b 45 08             	mov    0x8(%ebp),%eax
8010218f:	89 04 24             	mov    %eax,(%esp)
80102192:	e8 7a 32 00 00       	call   80105411 <strncmp>
}
80102197:	c9                   	leave  
80102198:	c3                   	ret    

80102199 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102199:	55                   	push   %ebp
8010219a:	89 e5                	mov    %esp,%ebp
8010219c:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010219f:	8b 45 08             	mov    0x8(%ebp),%eax
801021a2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021a6:	66 83 f8 01          	cmp    $0x1,%ax
801021aa:	74 0c                	je     801021b8 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801021ac:	c7 04 24 53 8a 10 80 	movl   $0x80108a53,(%esp)
801021b3:	e8 1f e4 ff ff       	call   801005d7 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021bf:	e9 88 00 00 00       	jmp    8010224c <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021c4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021cb:	00 
801021cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801021d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 9f fc ff ff       	call   80101e84 <readi>
801021e5:	83 f8 10             	cmp    $0x10,%eax
801021e8:	74 0c                	je     801021f6 <dirlookup+0x5d>
      panic("dirlink read");
801021ea:	c7 04 24 65 8a 10 80 	movl   $0x80108a65,(%esp)
801021f1:	e8 e1 e3 ff ff       	call   801005d7 <panic>
    if(de.inum == 0)
801021f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021fa:	66 85 c0             	test   %ax,%ax
801021fd:	75 02                	jne    80102201 <dirlookup+0x68>
      continue;
801021ff:	eb 47                	jmp    80102248 <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102201:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102204:	83 c0 02             	add    $0x2,%eax
80102207:	89 44 24 04          	mov    %eax,0x4(%esp)
8010220b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010220e:	89 04 24             	mov    %eax,(%esp)
80102211:	e8 61 ff ff ff       	call   80102177 <namecmp>
80102216:	85 c0                	test   %eax,%eax
80102218:	75 2e                	jne    80102248 <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010221a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010221e:	74 08                	je     80102228 <dirlookup+0x8f>
        *poff = off;
80102220:	8b 45 10             	mov    0x10(%ebp),%eax
80102223:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102226:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102228:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010222c:	0f b7 c0             	movzwl %ax,%eax
8010222f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102232:	8b 45 08             	mov    0x8(%ebp),%eax
80102235:	8b 00                	mov    (%eax),%eax
80102237:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010223a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010223e:	89 04 24             	mov    %eax,(%esp)
80102241:	e8 27 f6 ff ff       	call   8010186d <iget>
80102246:	eb 18                	jmp    80102260 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102248:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010224c:	8b 45 08             	mov    0x8(%ebp),%eax
8010224f:	8b 40 18             	mov    0x18(%eax),%eax
80102252:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102255:	0f 87 69 ff ff ff    	ja     801021c4 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010225b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102260:	c9                   	leave  
80102261:	c3                   	ret    

80102262 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102262:	55                   	push   %ebp
80102263:	89 e5                	mov    %esp,%ebp
80102265:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102268:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010226f:	00 
80102270:	8b 45 0c             	mov    0xc(%ebp),%eax
80102273:	89 44 24 04          	mov    %eax,0x4(%esp)
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	89 04 24             	mov    %eax,(%esp)
8010227d:	e8 17 ff ff ff       	call   80102199 <dirlookup>
80102282:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102285:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102289:	74 15                	je     801022a0 <dirlink+0x3e>
    iput(ip);
8010228b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010228e:	89 04 24             	mov    %eax,(%esp)
80102291:	e8 94 f8 ff ff       	call   80101b2a <iput>
    return -1;
80102296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010229b:	e9 b7 00 00 00       	jmp    80102357 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a7:	eb 46                	jmp    801022ef <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ac:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022b3:	00 
801022b4:	89 44 24 08          	mov    %eax,0x8(%esp)
801022b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801022bf:	8b 45 08             	mov    0x8(%ebp),%eax
801022c2:	89 04 24             	mov    %eax,(%esp)
801022c5:	e8 ba fb ff ff       	call   80101e84 <readi>
801022ca:	83 f8 10             	cmp    $0x10,%eax
801022cd:	74 0c                	je     801022db <dirlink+0x79>
      panic("dirlink read");
801022cf:	c7 04 24 65 8a 10 80 	movl   $0x80108a65,(%esp)
801022d6:	e8 fc e2 ff ff       	call   801005d7 <panic>
    if(de.inum == 0)
801022db:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022df:	66 85 c0             	test   %ax,%ax
801022e2:	75 02                	jne    801022e6 <dirlink+0x84>
      break;
801022e4:	eb 16                	jmp    801022fc <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e9:	83 c0 10             	add    $0x10,%eax
801022ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f2:	8b 45 08             	mov    0x8(%ebp),%eax
801022f5:	8b 40 18             	mov    0x18(%eax),%eax
801022f8:	39 c2                	cmp    %eax,%edx
801022fa:	72 ad                	jb     801022a9 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801022fc:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102303:	00 
80102304:	8b 45 0c             	mov    0xc(%ebp),%eax
80102307:	89 44 24 04          	mov    %eax,0x4(%esp)
8010230b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010230e:	83 c0 02             	add    $0x2,%eax
80102311:	89 04 24             	mov    %eax,(%esp)
80102314:	e8 4e 31 00 00       	call   80105467 <strncpy>
  de.inum = inum;
80102319:	8b 45 10             	mov    0x10(%ebp),%eax
8010231c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102323:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010232a:	00 
8010232b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010232f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102332:	89 44 24 04          	mov    %eax,0x4(%esp)
80102336:	8b 45 08             	mov    0x8(%ebp),%eax
80102339:	89 04 24             	mov    %eax,(%esp)
8010233c:	e8 a7 fc ff ff       	call   80101fe8 <writei>
80102341:	83 f8 10             	cmp    $0x10,%eax
80102344:	74 0c                	je     80102352 <dirlink+0xf0>
    panic("dirlink");
80102346:	c7 04 24 72 8a 10 80 	movl   $0x80108a72,(%esp)
8010234d:	e8 85 e2 ff ff       	call   801005d7 <panic>
  
  return 0;
80102352:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102357:	c9                   	leave  
80102358:	c3                   	ret    

80102359 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102359:	55                   	push   %ebp
8010235a:	89 e5                	mov    %esp,%ebp
8010235c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010235f:	eb 04                	jmp    80102365 <skipelem+0xc>
    path++;
80102361:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102365:	8b 45 08             	mov    0x8(%ebp),%eax
80102368:	0f b6 00             	movzbl (%eax),%eax
8010236b:	3c 2f                	cmp    $0x2f,%al
8010236d:	74 f2                	je     80102361 <skipelem+0x8>
    path++;
  if(*path == 0)
8010236f:	8b 45 08             	mov    0x8(%ebp),%eax
80102372:	0f b6 00             	movzbl (%eax),%eax
80102375:	84 c0                	test   %al,%al
80102377:	75 0a                	jne    80102383 <skipelem+0x2a>
    return 0;
80102379:	b8 00 00 00 00       	mov    $0x0,%eax
8010237e:	e9 86 00 00 00       	jmp    80102409 <skipelem+0xb0>
  s = path;
80102383:	8b 45 08             	mov    0x8(%ebp),%eax
80102386:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102389:	eb 04                	jmp    8010238f <skipelem+0x36>
    path++;
8010238b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010238f:	8b 45 08             	mov    0x8(%ebp),%eax
80102392:	0f b6 00             	movzbl (%eax),%eax
80102395:	3c 2f                	cmp    $0x2f,%al
80102397:	74 0a                	je     801023a3 <skipelem+0x4a>
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b6 00             	movzbl (%eax),%eax
8010239f:	84 c0                	test   %al,%al
801023a1:	75 e8                	jne    8010238b <skipelem+0x32>
    path++;
  len = path - s;
801023a3:	8b 55 08             	mov    0x8(%ebp),%edx
801023a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a9:	29 c2                	sub    %eax,%edx
801023ab:	89 d0                	mov    %edx,%eax
801023ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b0:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b4:	7e 1c                	jle    801023d2 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
801023b6:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023bd:	00 
801023be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801023c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c8:	89 04 24             	mov    %eax,(%esp)
801023cb:	e8 9e 2f 00 00       	call   8010536e <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023d0:	eb 2a                	jmp    801023fc <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801023d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d5:	89 44 24 08          	mov    %eax,0x8(%esp)
801023d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e3:	89 04 24             	mov    %eax,(%esp)
801023e6:	e8 83 2f 00 00       	call   8010536e <memmove>
    name[len] = 0;
801023eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801023f1:	01 d0                	add    %edx,%eax
801023f3:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f6:	eb 04                	jmp    801023fc <skipelem+0xa3>
    path++;
801023f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023fc:	8b 45 08             	mov    0x8(%ebp),%eax
801023ff:	0f b6 00             	movzbl (%eax),%eax
80102402:	3c 2f                	cmp    $0x2f,%al
80102404:	74 f2                	je     801023f8 <skipelem+0x9f>
    path++;
  return path;
80102406:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102409:	c9                   	leave  
8010240a:	c3                   	ret    

8010240b <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010240b:	55                   	push   %ebp
8010240c:	89 e5                	mov    %esp,%ebp
8010240e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102411:	8b 45 08             	mov    0x8(%ebp),%eax
80102414:	0f b6 00             	movzbl (%eax),%eax
80102417:	3c 2f                	cmp    $0x2f,%al
80102419:	75 1c                	jne    80102437 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010241b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102422:	00 
80102423:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010242a:	e8 3e f4 ff ff       	call   8010186d <iget>
8010242f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102432:	e9 af 00 00 00       	jmp    801024e6 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102437:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010243d:	8b 40 68             	mov    0x68(%eax),%eax
80102440:	89 04 24             	mov    %eax,(%esp)
80102443:	e8 f7 f4 ff ff       	call   8010193f <idup>
80102448:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010244b:	e9 96 00 00 00       	jmp    801024e6 <namex+0xdb>
    ilock(ip);
80102450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102453:	89 04 24             	mov    %eax,(%esp)
80102456:	e8 16 f5 ff ff       	call   80101971 <ilock>
    if(ip->type != T_DIR){
8010245b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102462:	66 83 f8 01          	cmp    $0x1,%ax
80102466:	74 15                	je     8010247d <namex+0x72>
      iunlockput(ip);
80102468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246b:	89 04 24             	mov    %eax,(%esp)
8010246e:	e8 88 f7 ff ff       	call   80101bfb <iunlockput>
      return 0;
80102473:	b8 00 00 00 00       	mov    $0x0,%eax
80102478:	e9 a3 00 00 00       	jmp    80102520 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010247d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102481:	74 1d                	je     801024a0 <namex+0x95>
80102483:	8b 45 08             	mov    0x8(%ebp),%eax
80102486:	0f b6 00             	movzbl (%eax),%eax
80102489:	84 c0                	test   %al,%al
8010248b:	75 13                	jne    801024a0 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
8010248d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102490:	89 04 24             	mov    %eax,(%esp)
80102493:	e8 2d f6 ff ff       	call   80101ac5 <iunlock>
      return ip;
80102498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249b:	e9 80 00 00 00       	jmp    80102520 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024a7:	00 
801024a8:	8b 45 10             	mov    0x10(%ebp),%eax
801024ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b2:	89 04 24             	mov    %eax,(%esp)
801024b5:	e8 df fc ff ff       	call   80102199 <dirlookup>
801024ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c1:	75 12                	jne    801024d5 <namex+0xca>
      iunlockput(ip);
801024c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c6:	89 04 24             	mov    %eax,(%esp)
801024c9:	e8 2d f7 ff ff       	call   80101bfb <iunlockput>
      return 0;
801024ce:	b8 00 00 00 00       	mov    $0x0,%eax
801024d3:	eb 4b                	jmp    80102520 <namex+0x115>
    }
    iunlockput(ip);
801024d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d8:	89 04 24             	mov    %eax,(%esp)
801024db:	e8 1b f7 ff ff       	call   80101bfb <iunlockput>
    ip = next;
801024e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024e6:	8b 45 10             	mov    0x10(%ebp),%eax
801024e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801024ed:	8b 45 08             	mov    0x8(%ebp),%eax
801024f0:	89 04 24             	mov    %eax,(%esp)
801024f3:	e8 61 fe ff ff       	call   80102359 <skipelem>
801024f8:	89 45 08             	mov    %eax,0x8(%ebp)
801024fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ff:	0f 85 4b ff ff ff    	jne    80102450 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102509:	74 12                	je     8010251d <namex+0x112>
    iput(ip);
8010250b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010250e:	89 04 24             	mov    %eax,(%esp)
80102511:	e8 14 f6 ff ff       	call   80101b2a <iput>
    return 0;
80102516:	b8 00 00 00 00       	mov    $0x0,%eax
8010251b:	eb 03                	jmp    80102520 <namex+0x115>
  }
  return ip;
8010251d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102520:	c9                   	leave  
80102521:	c3                   	ret    

80102522 <namei>:

struct inode*
namei(char *path)
{
80102522:	55                   	push   %ebp
80102523:	89 e5                	mov    %esp,%ebp
80102525:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102528:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010252b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010252f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102536:	00 
80102537:	8b 45 08             	mov    0x8(%ebp),%eax
8010253a:	89 04 24             	mov    %eax,(%esp)
8010253d:	e8 c9 fe ff ff       	call   8010240b <namex>
}
80102542:	c9                   	leave  
80102543:	c3                   	ret    

80102544 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102544:	55                   	push   %ebp
80102545:	89 e5                	mov    %esp,%ebp
80102547:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010254a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010254d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102551:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102558:	00 
80102559:	8b 45 08             	mov    0x8(%ebp),%eax
8010255c:	89 04 24             	mov    %eax,(%esp)
8010255f:	e8 a7 fe ff ff       	call   8010240b <namex>
}
80102564:	c9                   	leave  
80102565:	c3                   	ret    

80102566 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102566:	55                   	push   %ebp
80102567:	89 e5                	mov    %esp,%ebp
80102569:	83 ec 14             	sub    $0x14,%esp
8010256c:	8b 45 08             	mov    0x8(%ebp),%eax
8010256f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102573:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102577:	89 c2                	mov    %eax,%edx
80102579:	ec                   	in     (%dx),%al
8010257a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010257d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102581:	c9                   	leave  
80102582:	c3                   	ret    

80102583 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102583:	55                   	push   %ebp
80102584:	89 e5                	mov    %esp,%ebp
80102586:	57                   	push   %edi
80102587:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102588:	8b 55 08             	mov    0x8(%ebp),%edx
8010258b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010258e:	8b 45 10             	mov    0x10(%ebp),%eax
80102591:	89 cb                	mov    %ecx,%ebx
80102593:	89 df                	mov    %ebx,%edi
80102595:	89 c1                	mov    %eax,%ecx
80102597:	fc                   	cld    
80102598:	f3 6d                	rep insl (%dx),%es:(%edi)
8010259a:	89 c8                	mov    %ecx,%eax
8010259c:	89 fb                	mov    %edi,%ebx
8010259e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025a1:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025a4:	5b                   	pop    %ebx
801025a5:	5f                   	pop    %edi
801025a6:	5d                   	pop    %ebp
801025a7:	c3                   	ret    

801025a8 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025a8:	55                   	push   %ebp
801025a9:	89 e5                	mov    %esp,%ebp
801025ab:	83 ec 08             	sub    $0x8,%esp
801025ae:	8b 55 08             	mov    0x8(%ebp),%edx
801025b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801025b4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025b8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025bb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025bf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025c3:	ee                   	out    %al,(%dx)
}
801025c4:	c9                   	leave  
801025c5:	c3                   	ret    

801025c6 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025c6:	55                   	push   %ebp
801025c7:	89 e5                	mov    %esp,%ebp
801025c9:	56                   	push   %esi
801025ca:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025cb:	8b 55 08             	mov    0x8(%ebp),%edx
801025ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025d1:	8b 45 10             	mov    0x10(%ebp),%eax
801025d4:	89 cb                	mov    %ecx,%ebx
801025d6:	89 de                	mov    %ebx,%esi
801025d8:	89 c1                	mov    %eax,%ecx
801025da:	fc                   	cld    
801025db:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025dd:	89 c8                	mov    %ecx,%eax
801025df:	89 f3                	mov    %esi,%ebx
801025e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025e4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025e7:	5b                   	pop    %ebx
801025e8:	5e                   	pop    %esi
801025e9:	5d                   	pop    %ebp
801025ea:	c3                   	ret    

801025eb <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025f1:	90                   	nop
801025f2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025f9:	e8 68 ff ff ff       	call   80102566 <inb>
801025fe:	0f b6 c0             	movzbl %al,%eax
80102601:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102604:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102607:	25 c0 00 00 00       	and    $0xc0,%eax
8010260c:	83 f8 40             	cmp    $0x40,%eax
8010260f:	75 e1                	jne    801025f2 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102611:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102615:	74 11                	je     80102628 <idewait+0x3d>
80102617:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010261a:	83 e0 21             	and    $0x21,%eax
8010261d:	85 c0                	test   %eax,%eax
8010261f:	74 07                	je     80102628 <idewait+0x3d>
    return -1;
80102621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102626:	eb 05                	jmp    8010262d <idewait+0x42>
  return 0;
80102628:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262d:	c9                   	leave  
8010262e:	c3                   	ret    

8010262f <ideinit>:

void
ideinit(void)
{
8010262f:	55                   	push   %ebp
80102630:	89 e5                	mov    %esp,%ebp
80102632:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102635:	c7 44 24 04 7a 8a 10 	movl   $0x80108a7a,0x4(%esp)
8010263c:	80 
8010263d:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102644:	e8 e1 29 00 00       	call   8010502a <initlock>
  picenable(IRQ_IDE);
80102649:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102650:	e8 fb 18 00 00       	call   80103f50 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102655:	a1 20 33 11 80       	mov    0x80113320,%eax
8010265a:	83 e8 01             	sub    $0x1,%eax
8010265d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102661:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102668:	e8 43 04 00 00       	call   80102ab0 <ioapicenable>
  idewait(0);
8010266d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102674:	e8 72 ff ff ff       	call   801025eb <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102679:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102680:	00 
80102681:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102688:	e8 1b ff ff ff       	call   801025a8 <outb>
  for(i=0; i<1000; i++){
8010268d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102694:	eb 20                	jmp    801026b6 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102696:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010269d:	e8 c4 fe ff ff       	call   80102566 <inb>
801026a2:	84 c0                	test   %al,%al
801026a4:	74 0c                	je     801026b2 <ideinit+0x83>
      havedisk1 = 1;
801026a6:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
801026ad:	00 00 00 
      break;
801026b0:	eb 0d                	jmp    801026bf <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026b6:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026bd:	7e d7                	jle    80102696 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026bf:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801026c6:	00 
801026c7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026ce:	e8 d5 fe ff ff       	call   801025a8 <outb>
}
801026d3:	c9                   	leave  
801026d4:	c3                   	ret    

801026d5 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026d5:	55                   	push   %ebp
801026d6:	89 e5                	mov    %esp,%ebp
801026d8:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801026db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026df:	75 0c                	jne    801026ed <idestart+0x18>
    panic("idestart");
801026e1:	c7 04 24 7e 8a 10 80 	movl   $0x80108a7e,(%esp)
801026e8:	e8 ea de ff ff       	call   801005d7 <panic>
  if(b->blockno >= FSSIZE)
801026ed:	8b 45 08             	mov    0x8(%ebp),%eax
801026f0:	8b 40 08             	mov    0x8(%eax),%eax
801026f3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026f8:	76 0c                	jbe    80102706 <idestart+0x31>
    panic("incorrect blockno");
801026fa:	c7 04 24 87 8a 10 80 	movl   $0x80108a87,(%esp)
80102701:	e8 d1 de ff ff       	call   801005d7 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102706:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	8b 50 08             	mov    0x8(%eax),%edx
80102713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102716:	0f af c2             	imul   %edx,%eax
80102719:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010271c:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102720:	7e 0c                	jle    8010272e <idestart+0x59>
80102722:	c7 04 24 7e 8a 10 80 	movl   $0x80108a7e,(%esp)
80102729:	e8 a9 de ff ff       	call   801005d7 <panic>
  
  idewait(0);
8010272e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102735:	e8 b1 fe ff ff       	call   801025eb <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010273a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102741:	00 
80102742:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102749:	e8 5a fe ff ff       	call   801025a8 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
8010274e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102751:	0f b6 c0             	movzbl %al,%eax
80102754:	89 44 24 04          	mov    %eax,0x4(%esp)
80102758:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010275f:	e8 44 fe ff ff       	call   801025a8 <outb>
  outb(0x1f3, sector & 0xff);
80102764:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102767:	0f b6 c0             	movzbl %al,%eax
8010276a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010276e:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102775:	e8 2e fe ff ff       	call   801025a8 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
8010277a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010277d:	c1 f8 08             	sar    $0x8,%eax
80102780:	0f b6 c0             	movzbl %al,%eax
80102783:	89 44 24 04          	mov    %eax,0x4(%esp)
80102787:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010278e:	e8 15 fe ff ff       	call   801025a8 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102796:	c1 f8 10             	sar    $0x10,%eax
80102799:	0f b6 c0             	movzbl %al,%eax
8010279c:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a0:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801027a7:	e8 fc fd ff ff       	call   801025a8 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027ac:	8b 45 08             	mov    0x8(%ebp),%eax
801027af:	8b 40 04             	mov    0x4(%eax),%eax
801027b2:	83 e0 01             	and    $0x1,%eax
801027b5:	c1 e0 04             	shl    $0x4,%eax
801027b8:	89 c2                	mov    %eax,%edx
801027ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027bd:	c1 f8 18             	sar    $0x18,%eax
801027c0:	83 e0 0f             	and    $0xf,%eax
801027c3:	09 d0                	or     %edx,%eax
801027c5:	83 c8 e0             	or     $0xffffffe0,%eax
801027c8:	0f b6 c0             	movzbl %al,%eax
801027cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801027cf:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027d6:	e8 cd fd ff ff       	call   801025a8 <outb>
  if(b->flags & B_DIRTY){
801027db:	8b 45 08             	mov    0x8(%ebp),%eax
801027de:	8b 00                	mov    (%eax),%eax
801027e0:	83 e0 04             	and    $0x4,%eax
801027e3:	85 c0                	test   %eax,%eax
801027e5:	74 34                	je     8010281b <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
801027e7:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801027ee:	00 
801027ef:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027f6:	e8 ad fd ff ff       	call   801025a8 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	83 c0 18             	add    $0x18,%eax
80102801:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102808:	00 
80102809:	89 44 24 04          	mov    %eax,0x4(%esp)
8010280d:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102814:	e8 ad fd ff ff       	call   801025c6 <outsl>
80102819:	eb 14                	jmp    8010282f <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010281b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102822:	00 
80102823:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010282a:	e8 79 fd ff ff       	call   801025a8 <outb>
  }
}
8010282f:	c9                   	leave  
80102830:	c3                   	ret    

80102831 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102831:	55                   	push   %ebp
80102832:	89 e5                	mov    %esp,%ebp
80102834:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102837:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
8010283e:	e8 08 28 00 00       	call   8010504b <acquire>
  if((b = idequeue) == 0){
80102843:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102848:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010284b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010284f:	75 11                	jne    80102862 <ideintr+0x31>
    release(&idelock);
80102851:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102858:	e8 50 28 00 00       	call   801050ad <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010285d:	e9 90 00 00 00       	jmp    801028f2 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102865:	8b 40 14             	mov    0x14(%eax),%eax
80102868:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010286d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102870:	8b 00                	mov    (%eax),%eax
80102872:	83 e0 04             	and    $0x4,%eax
80102875:	85 c0                	test   %eax,%eax
80102877:	75 2e                	jne    801028a7 <ideintr+0x76>
80102879:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102880:	e8 66 fd ff ff       	call   801025eb <idewait>
80102885:	85 c0                	test   %eax,%eax
80102887:	78 1e                	js     801028a7 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010288c:	83 c0 18             	add    $0x18,%eax
8010288f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102896:	00 
80102897:	89 44 24 04          	mov    %eax,0x4(%esp)
8010289b:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801028a2:	e8 dc fc ff ff       	call   80102583 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028aa:	8b 00                	mov    (%eax),%eax
801028ac:	83 c8 02             	or     $0x2,%eax
801028af:	89 c2                	mov    %eax,%edx
801028b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b9:	8b 00                	mov    (%eax),%eax
801028bb:	83 e0 fb             	and    $0xfffffffb,%eax
801028be:	89 c2                	mov    %eax,%edx
801028c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c8:	89 04 24             	mov    %eax,(%esp)
801028cb:	e8 80 25 00 00       	call   80104e50 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028d0:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028d5:	85 c0                	test   %eax,%eax
801028d7:	74 0d                	je     801028e6 <ideintr+0xb5>
    idestart(idequeue);
801028d9:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028de:	89 04 24             	mov    %eax,(%esp)
801028e1:	e8 ef fd ff ff       	call   801026d5 <idestart>

  release(&idelock);
801028e6:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801028ed:	e8 bb 27 00 00       	call   801050ad <release>
}
801028f2:	c9                   	leave  
801028f3:	c3                   	ret    

801028f4 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801028f4:	55                   	push   %ebp
801028f5:	89 e5                	mov    %esp,%ebp
801028f7:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801028fa:	8b 45 08             	mov    0x8(%ebp),%eax
801028fd:	8b 00                	mov    (%eax),%eax
801028ff:	83 e0 01             	and    $0x1,%eax
80102902:	85 c0                	test   %eax,%eax
80102904:	75 0c                	jne    80102912 <iderw+0x1e>
    panic("iderw: buf not busy");
80102906:	c7 04 24 99 8a 10 80 	movl   $0x80108a99,(%esp)
8010290d:	e8 c5 dc ff ff       	call   801005d7 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102912:	8b 45 08             	mov    0x8(%ebp),%eax
80102915:	8b 00                	mov    (%eax),%eax
80102917:	83 e0 06             	and    $0x6,%eax
8010291a:	83 f8 02             	cmp    $0x2,%eax
8010291d:	75 0c                	jne    8010292b <iderw+0x37>
    panic("iderw: nothing to do");
8010291f:	c7 04 24 ad 8a 10 80 	movl   $0x80108aad,(%esp)
80102926:	e8 ac dc ff ff       	call   801005d7 <panic>
  if(b->dev != 0 && !havedisk1)
8010292b:	8b 45 08             	mov    0x8(%ebp),%eax
8010292e:	8b 40 04             	mov    0x4(%eax),%eax
80102931:	85 c0                	test   %eax,%eax
80102933:	74 15                	je     8010294a <iderw+0x56>
80102935:	a1 58 b6 10 80       	mov    0x8010b658,%eax
8010293a:	85 c0                	test   %eax,%eax
8010293c:	75 0c                	jne    8010294a <iderw+0x56>
    panic("iderw: ide disk 1 not present");
8010293e:	c7 04 24 c2 8a 10 80 	movl   $0x80108ac2,(%esp)
80102945:	e8 8d dc ff ff       	call   801005d7 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010294a:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102951:	e8 f5 26 00 00       	call   8010504b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102956:	8b 45 08             	mov    0x8(%ebp),%eax
80102959:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102960:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
80102967:	eb 0b                	jmp    80102974 <iderw+0x80>
80102969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296c:	8b 00                	mov    (%eax),%eax
8010296e:	83 c0 14             	add    $0x14,%eax
80102971:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102977:	8b 00                	mov    (%eax),%eax
80102979:	85 c0                	test   %eax,%eax
8010297b:	75 ec                	jne    80102969 <iderw+0x75>
    ;
  *pp = b;
8010297d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102980:	8b 55 08             	mov    0x8(%ebp),%edx
80102983:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102985:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010298a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010298d:	75 0d                	jne    8010299c <iderw+0xa8>
    idestart(b);
8010298f:	8b 45 08             	mov    0x8(%ebp),%eax
80102992:	89 04 24             	mov    %eax,(%esp)
80102995:	e8 3b fd ff ff       	call   801026d5 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010299a:	eb 15                	jmp    801029b1 <iderw+0xbd>
8010299c:	eb 13                	jmp    801029b1 <iderw+0xbd>
    sleep(b, &idelock);
8010299e:	c7 44 24 04 20 b6 10 	movl   $0x8010b620,0x4(%esp)
801029a5:	80 
801029a6:	8b 45 08             	mov    0x8(%ebp),%eax
801029a9:	89 04 24             	mov    %eax,(%esp)
801029ac:	e8 c6 23 00 00       	call   80104d77 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029b1:	8b 45 08             	mov    0x8(%ebp),%eax
801029b4:	8b 00                	mov    (%eax),%eax
801029b6:	83 e0 06             	and    $0x6,%eax
801029b9:	83 f8 02             	cmp    $0x2,%eax
801029bc:	75 e0                	jne    8010299e <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
801029be:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801029c5:	e8 e3 26 00 00       	call   801050ad <release>
}
801029ca:	c9                   	leave  
801029cb:	c3                   	ret    

801029cc <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029cc:	55                   	push   %ebp
801029cd:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029cf:	a1 f4 2b 11 80       	mov    0x80112bf4,%eax
801029d4:	8b 55 08             	mov    0x8(%ebp),%edx
801029d7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029d9:	a1 f4 2b 11 80       	mov    0x80112bf4,%eax
801029de:	8b 40 10             	mov    0x10(%eax),%eax
}
801029e1:	5d                   	pop    %ebp
801029e2:	c3                   	ret    

801029e3 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801029e3:	55                   	push   %ebp
801029e4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029e6:	a1 f4 2b 11 80       	mov    0x80112bf4,%eax
801029eb:	8b 55 08             	mov    0x8(%ebp),%edx
801029ee:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801029f0:	a1 f4 2b 11 80       	mov    0x80112bf4,%eax
801029f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801029f8:	89 50 10             	mov    %edx,0x10(%eax)
}
801029fb:	5d                   	pop    %ebp
801029fc:	c3                   	ret    

801029fd <ioapicinit>:

void
ioapicinit(void)
{
801029fd:	55                   	push   %ebp
801029fe:	89 e5                	mov    %esp,%ebp
80102a00:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102a03:	a1 24 2d 11 80       	mov    0x80112d24,%eax
80102a08:	85 c0                	test   %eax,%eax
80102a0a:	75 05                	jne    80102a11 <ioapicinit+0x14>
    return;
80102a0c:	e9 9d 00 00 00       	jmp    80102aae <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a11:	c7 05 f4 2b 11 80 00 	movl   $0xfec00000,0x80112bf4
80102a18:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a22:	e8 a5 ff ff ff       	call   801029cc <ioapicread>
80102a27:	c1 e8 10             	shr    $0x10,%eax
80102a2a:	25 ff 00 00 00       	and    $0xff,%eax
80102a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102a39:	e8 8e ff ff ff       	call   801029cc <ioapicread>
80102a3e:	c1 e8 18             	shr    $0x18,%eax
80102a41:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a44:	0f b6 05 20 2d 11 80 	movzbl 0x80112d20,%eax
80102a4b:	0f b6 c0             	movzbl %al,%eax
80102a4e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a51:	74 0c                	je     80102a5f <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a53:	c7 04 24 e0 8a 10 80 	movl   $0x80108ae0,(%esp)
80102a5a:	e8 a4 d9 ff ff       	call   80100403 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a66:	eb 3e                	jmp    80102aa6 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6b:	83 c0 20             	add    $0x20,%eax
80102a6e:	0d 00 00 01 00       	or     $0x10000,%eax
80102a73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a76:	83 c2 08             	add    $0x8,%edx
80102a79:	01 d2                	add    %edx,%edx
80102a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a7f:	89 14 24             	mov    %edx,(%esp)
80102a82:	e8 5c ff ff ff       	call   801029e3 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8a:	83 c0 08             	add    $0x8,%eax
80102a8d:	01 c0                	add    %eax,%eax
80102a8f:	83 c0 01             	add    $0x1,%eax
80102a92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a99:	00 
80102a9a:	89 04 24             	mov    %eax,(%esp)
80102a9d:	e8 41 ff ff ff       	call   801029e3 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102aa2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102aac:	7e ba                	jle    80102a68 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102aae:	c9                   	leave  
80102aaf:	c3                   	ret    

80102ab0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ab0:	55                   	push   %ebp
80102ab1:	89 e5                	mov    %esp,%ebp
80102ab3:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102ab6:	a1 24 2d 11 80       	mov    0x80112d24,%eax
80102abb:	85 c0                	test   %eax,%eax
80102abd:	75 02                	jne    80102ac1 <ioapicenable+0x11>
    return;
80102abf:	eb 37                	jmp    80102af8 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac4:	83 c0 20             	add    $0x20,%eax
80102ac7:	8b 55 08             	mov    0x8(%ebp),%edx
80102aca:	83 c2 08             	add    $0x8,%edx
80102acd:	01 d2                	add    %edx,%edx
80102acf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ad3:	89 14 24             	mov    %edx,(%esp)
80102ad6:	e8 08 ff ff ff       	call   801029e3 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102adb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ade:	c1 e0 18             	shl    $0x18,%eax
80102ae1:	8b 55 08             	mov    0x8(%ebp),%edx
80102ae4:	83 c2 08             	add    $0x8,%edx
80102ae7:	01 d2                	add    %edx,%edx
80102ae9:	83 c2 01             	add    $0x1,%edx
80102aec:	89 44 24 04          	mov    %eax,0x4(%esp)
80102af0:	89 14 24             	mov    %edx,(%esp)
80102af3:	e8 eb fe ff ff       	call   801029e3 <ioapicwrite>
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp
80102afd:	8b 45 08             	mov    0x8(%ebp),%eax
80102b00:	05 00 00 00 80       	add    $0x80000000,%eax
80102b05:	5d                   	pop    %ebp
80102b06:	c3                   	ret    

80102b07 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b07:	55                   	push   %ebp
80102b08:	89 e5                	mov    %esp,%ebp
80102b0a:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102b0d:	c7 44 24 04 12 8b 10 	movl   $0x80108b12,0x4(%esp)
80102b14:	80 
80102b15:	c7 04 24 00 2c 11 80 	movl   $0x80112c00,(%esp)
80102b1c:	e8 09 25 00 00       	call   8010502a <initlock>
  kmem.use_lock = 0;
80102b21:	c7 05 34 2c 11 80 00 	movl   $0x0,0x80112c34
80102b28:	00 00 00 
  freerange(vstart, vend);
80102b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b32:	8b 45 08             	mov    0x8(%ebp),%eax
80102b35:	89 04 24             	mov    %eax,(%esp)
80102b38:	e8 26 00 00 00       	call   80102b63 <freerange>
}
80102b3d:	c9                   	leave  
80102b3e:	c3                   	ret    

80102b3f <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b3f:	55                   	push   %ebp
80102b40:	89 e5                	mov    %esp,%ebp
80102b42:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4f:	89 04 24             	mov    %eax,(%esp)
80102b52:	e8 0c 00 00 00       	call   80102b63 <freerange>
  kmem.use_lock = 1;
80102b57:	c7 05 34 2c 11 80 01 	movl   $0x1,0x80112c34
80102b5e:	00 00 00 
}
80102b61:	c9                   	leave  
80102b62:	c3                   	ret    

80102b63 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b63:	55                   	push   %ebp
80102b64:	89 e5                	mov    %esp,%ebp
80102b66:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b69:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6c:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b79:	eb 12                	jmp    80102b8d <freerange+0x2a>
    kfree(p);
80102b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7e:	89 04 24             	mov    %eax,(%esp)
80102b81:	e8 16 00 00 00       	call   80102b9c <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b86:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b90:	05 00 10 00 00       	add    $0x1000,%eax
80102b95:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b98:	76 e1                	jbe    80102b7b <freerange+0x18>
    kfree(p);
}
80102b9a:	c9                   	leave  
80102b9b:	c3                   	ret    

80102b9c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b9c:	55                   	push   %ebp
80102b9d:	89 e5                	mov    %esp,%ebp
80102b9f:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba5:	25 ff 0f 00 00       	and    $0xfff,%eax
80102baa:	85 c0                	test   %eax,%eax
80102bac:	75 1b                	jne    80102bc9 <kfree+0x2d>
80102bae:	81 7d 08 1c 5c 11 80 	cmpl   $0x80115c1c,0x8(%ebp)
80102bb5:	72 12                	jb     80102bc9 <kfree+0x2d>
80102bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bba:	89 04 24             	mov    %eax,(%esp)
80102bbd:	e8 38 ff ff ff       	call   80102afa <v2p>
80102bc2:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bc7:	76 0c                	jbe    80102bd5 <kfree+0x39>
    panic("kfree");
80102bc9:	c7 04 24 17 8b 10 80 	movl   $0x80108b17,(%esp)
80102bd0:	e8 02 da ff ff       	call   801005d7 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102bd5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102bdc:	00 
80102bdd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102be4:	00 
80102be5:	8b 45 08             	mov    0x8(%ebp),%eax
80102be8:	89 04 24             	mov    %eax,(%esp)
80102beb:	e8 af 26 00 00       	call   8010529f <memset>

  if(kmem.use_lock)
80102bf0:	a1 34 2c 11 80       	mov    0x80112c34,%eax
80102bf5:	85 c0                	test   %eax,%eax
80102bf7:	74 0c                	je     80102c05 <kfree+0x69>
    acquire(&kmem.lock);
80102bf9:	c7 04 24 00 2c 11 80 	movl   $0x80112c00,(%esp)
80102c00:	e8 46 24 00 00       	call   8010504b <acquire>
  r = (struct run*)v;
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c0b:	8b 15 38 2c 11 80    	mov    0x80112c38,%edx
80102c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c14:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c19:	a3 38 2c 11 80       	mov    %eax,0x80112c38
  if(kmem.use_lock)
80102c1e:	a1 34 2c 11 80       	mov    0x80112c34,%eax
80102c23:	85 c0                	test   %eax,%eax
80102c25:	74 0c                	je     80102c33 <kfree+0x97>
    release(&kmem.lock);
80102c27:	c7 04 24 00 2c 11 80 	movl   $0x80112c00,(%esp)
80102c2e:	e8 7a 24 00 00       	call   801050ad <release>
}
80102c33:	c9                   	leave  
80102c34:	c3                   	ret    

80102c35 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c35:	55                   	push   %ebp
80102c36:	89 e5                	mov    %esp,%ebp
80102c38:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102c3b:	a1 34 2c 11 80       	mov    0x80112c34,%eax
80102c40:	85 c0                	test   %eax,%eax
80102c42:	74 0c                	je     80102c50 <kalloc+0x1b>
    acquire(&kmem.lock);
80102c44:	c7 04 24 00 2c 11 80 	movl   $0x80112c00,(%esp)
80102c4b:	e8 fb 23 00 00       	call   8010504b <acquire>
  r = kmem.freelist;
80102c50:	a1 38 2c 11 80       	mov    0x80112c38,%eax
80102c55:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c5c:	74 0a                	je     80102c68 <kalloc+0x33>
    kmem.freelist = r->next;
80102c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c61:	8b 00                	mov    (%eax),%eax
80102c63:	a3 38 2c 11 80       	mov    %eax,0x80112c38
  if(kmem.use_lock)
80102c68:	a1 34 2c 11 80       	mov    0x80112c34,%eax
80102c6d:	85 c0                	test   %eax,%eax
80102c6f:	74 0c                	je     80102c7d <kalloc+0x48>
    release(&kmem.lock);
80102c71:	c7 04 24 00 2c 11 80 	movl   $0x80112c00,(%esp)
80102c78:	e8 30 24 00 00       	call   801050ad <release>
  return (char*)r;
80102c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c80:	c9                   	leave  
80102c81:	c3                   	ret    

80102c82 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c82:	55                   	push   %ebp
80102c83:	89 e5                	mov    %esp,%ebp
80102c85:	83 ec 14             	sub    $0x14,%esp
80102c88:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c8f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c93:	89 c2                	mov    %eax,%edx
80102c95:	ec                   	in     (%dx),%al
80102c96:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c99:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c9d:	c9                   	leave  
80102c9e:	c3                   	ret    

80102c9f <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c9f:	55                   	push   %ebp
80102ca0:	89 e5                	mov    %esp,%ebp
80102ca2:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ca5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102cac:	e8 d1 ff ff ff       	call   80102c82 <inb>
80102cb1:	0f b6 c0             	movzbl %al,%eax
80102cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cba:	83 e0 01             	and    $0x1,%eax
80102cbd:	85 c0                	test   %eax,%eax
80102cbf:	75 0a                	jne    80102ccb <kbdgetc+0x2c>
    return -1;
80102cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102cc6:	e9 25 01 00 00       	jmp    80102df0 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102ccb:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102cd2:	e8 ab ff ff ff       	call   80102c82 <inb>
80102cd7:	0f b6 c0             	movzbl %al,%eax
80102cda:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102cdd:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ce4:	75 17                	jne    80102cfd <kbdgetc+0x5e>
    shift |= E0ESC;
80102ce6:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ceb:	83 c8 40             	or     $0x40,%eax
80102cee:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102cf3:	b8 00 00 00 00       	mov    $0x0,%eax
80102cf8:	e9 f3 00 00 00       	jmp    80102df0 <kbdgetc+0x151>
  } else if(data & 0x80){
80102cfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d00:	25 80 00 00 00       	and    $0x80,%eax
80102d05:	85 c0                	test   %eax,%eax
80102d07:	74 45                	je     80102d4e <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d09:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d0e:	83 e0 40             	and    $0x40,%eax
80102d11:	85 c0                	test   %eax,%eax
80102d13:	75 08                	jne    80102d1d <kbdgetc+0x7e>
80102d15:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d18:	83 e0 7f             	and    $0x7f,%eax
80102d1b:	eb 03                	jmp    80102d20 <kbdgetc+0x81>
80102d1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d20:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d26:	05 20 90 10 80       	add    $0x80109020,%eax
80102d2b:	0f b6 00             	movzbl (%eax),%eax
80102d2e:	83 c8 40             	or     $0x40,%eax
80102d31:	0f b6 c0             	movzbl %al,%eax
80102d34:	f7 d0                	not    %eax
80102d36:	89 c2                	mov    %eax,%edx
80102d38:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d3d:	21 d0                	and    %edx,%eax
80102d3f:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102d44:	b8 00 00 00 00       	mov    $0x0,%eax
80102d49:	e9 a2 00 00 00       	jmp    80102df0 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102d4e:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d53:	83 e0 40             	and    $0x40,%eax
80102d56:	85 c0                	test   %eax,%eax
80102d58:	74 14                	je     80102d6e <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d5a:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d61:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d66:	83 e0 bf             	and    $0xffffffbf,%eax
80102d69:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102d6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d71:	05 20 90 10 80       	add    $0x80109020,%eax
80102d76:	0f b6 00             	movzbl (%eax),%eax
80102d79:	0f b6 d0             	movzbl %al,%edx
80102d7c:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d81:	09 d0                	or     %edx,%eax
80102d83:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102d88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8b:	05 20 91 10 80       	add    $0x80109120,%eax
80102d90:	0f b6 00             	movzbl (%eax),%eax
80102d93:	0f b6 d0             	movzbl %al,%edx
80102d96:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d9b:	31 d0                	xor    %edx,%eax
80102d9d:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102da2:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102da7:	83 e0 03             	and    $0x3,%eax
80102daa:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102db1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102db4:	01 d0                	add    %edx,%eax
80102db6:	0f b6 00             	movzbl (%eax),%eax
80102db9:	0f b6 c0             	movzbl %al,%eax
80102dbc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102dbf:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102dc4:	83 e0 08             	and    $0x8,%eax
80102dc7:	85 c0                	test   %eax,%eax
80102dc9:	74 22                	je     80102ded <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102dcb:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102dcf:	76 0c                	jbe    80102ddd <kbdgetc+0x13e>
80102dd1:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102dd5:	77 06                	ja     80102ddd <kbdgetc+0x13e>
      c += 'A' - 'a';
80102dd7:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ddb:	eb 10                	jmp    80102ded <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102ddd:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102de1:	76 0a                	jbe    80102ded <kbdgetc+0x14e>
80102de3:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102de7:	77 04                	ja     80102ded <kbdgetc+0x14e>
      c += 'a' - 'A';
80102de9:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ded:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102df0:	c9                   	leave  
80102df1:	c3                   	ret    

80102df2 <kbdintr>:

void
kbdintr(void)
{
80102df2:	55                   	push   %ebp
80102df3:	89 e5                	mov    %esp,%ebp
80102df5:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102df8:	c7 04 24 9f 2c 10 80 	movl   $0x80102c9f,(%esp)
80102dff:	e8 61 da ff ff       	call   80100865 <consoleintr>
}
80102e04:	c9                   	leave  
80102e05:	c3                   	ret    

80102e06 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e06:	55                   	push   %ebp
80102e07:	89 e5                	mov    %esp,%ebp
80102e09:	83 ec 14             	sub    $0x14,%esp
80102e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e13:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e17:	89 c2                	mov    %eax,%edx
80102e19:	ec                   	in     (%dx),%al
80102e1a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e1d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e21:	c9                   	leave  
80102e22:	c3                   	ret    

80102e23 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e23:	55                   	push   %ebp
80102e24:	89 e5                	mov    %esp,%ebp
80102e26:	83 ec 08             	sub    $0x8,%esp
80102e29:	8b 55 08             	mov    0x8(%ebp),%edx
80102e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e2f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e33:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e36:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e3a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e3e:	ee                   	out    %al,(%dx)
}
80102e3f:	c9                   	leave  
80102e40:	c3                   	ret    

80102e41 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e41:	55                   	push   %ebp
80102e42:	89 e5                	mov    %esp,%ebp
80102e44:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e47:	9c                   	pushf  
80102e48:	58                   	pop    %eax
80102e49:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e4f:	c9                   	leave  
80102e50:	c3                   	ret    

80102e51 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e51:	55                   	push   %ebp
80102e52:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e54:	a1 3c 2c 11 80       	mov    0x80112c3c,%eax
80102e59:	8b 55 08             	mov    0x8(%ebp),%edx
80102e5c:	c1 e2 02             	shl    $0x2,%edx
80102e5f:	01 c2                	add    %eax,%edx
80102e61:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e64:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e66:	a1 3c 2c 11 80       	mov    0x80112c3c,%eax
80102e6b:	83 c0 20             	add    $0x20,%eax
80102e6e:	8b 00                	mov    (%eax),%eax
}
80102e70:	5d                   	pop    %ebp
80102e71:	c3                   	ret    

80102e72 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e72:	55                   	push   %ebp
80102e73:	89 e5                	mov    %esp,%ebp
80102e75:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102e78:	a1 3c 2c 11 80       	mov    0x80112c3c,%eax
80102e7d:	85 c0                	test   %eax,%eax
80102e7f:	75 05                	jne    80102e86 <lapicinit+0x14>
    return;
80102e81:	e9 43 01 00 00       	jmp    80102fc9 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e86:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102e8d:	00 
80102e8e:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102e95:	e8 b7 ff ff ff       	call   80102e51 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e9a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102ea1:	00 
80102ea2:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102ea9:	e8 a3 ff ff ff       	call   80102e51 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eae:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102eb5:	00 
80102eb6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ebd:	e8 8f ff ff ff       	call   80102e51 <lapicw>
  lapicw(TICR, 10000000); 
80102ec2:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102ec9:	00 
80102eca:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102ed1:	e8 7b ff ff ff       	call   80102e51 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ed6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102edd:	00 
80102ede:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102ee5:	e8 67 ff ff ff       	call   80102e51 <lapicw>
  lapicw(LINT1, MASKED);
80102eea:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102ef1:	00 
80102ef2:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102ef9:	e8 53 ff ff ff       	call   80102e51 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102efe:	a1 3c 2c 11 80       	mov    0x80112c3c,%eax
80102f03:	83 c0 30             	add    $0x30,%eax
80102f06:	8b 00                	mov    (%eax),%eax
80102f08:	c1 e8 10             	shr    $0x10,%eax
80102f0b:	0f b6 c0             	movzbl %al,%eax
80102f0e:	83 f8 03             	cmp    $0x3,%eax
80102f11:	76 14                	jbe    80102f27 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102f13:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f1a:	00 
80102f1b:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102f22:	e8 2a ff ff ff       	call   80102e51 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f27:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102f2e:	00 
80102f2f:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102f36:	e8 16 ff ff ff       	call   80102e51 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f42:	00 
80102f43:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f4a:	e8 02 ff ff ff       	call   80102e51 <lapicw>
  lapicw(ESR, 0);
80102f4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f56:	00 
80102f57:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f5e:	e8 ee fe ff ff       	call   80102e51 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f6a:	00 
80102f6b:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f72:	e8 da fe ff ff       	call   80102e51 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f7e:	00 
80102f7f:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f86:	e8 c6 fe ff ff       	call   80102e51 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f8b:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102f92:	00 
80102f93:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f9a:	e8 b2 fe ff ff       	call   80102e51 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f9f:	90                   	nop
80102fa0:	a1 3c 2c 11 80       	mov    0x80112c3c,%eax
80102fa5:	05 00 03 00 00       	add    $0x300,%eax
80102faa:	8b 00                	mov    (%eax),%eax
80102fac:	25 00 10 00 00       	and    $0x1000,%eax
80102fb1:	85 c0                	test   %eax,%eax
80102fb3:	75 eb                	jne    80102fa0 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fbc:	00 
80102fbd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102fc4:	e8 88 fe ff ff       	call   80102e51 <lapicw>
}
80102fc9:	c9                   	leave  
80102fca:	c3                   	ret    

80102fcb <cpunum>:

int
cpunum(void)
{
80102fcb:	55                   	push   %ebp
80102fcc:	89 e5                	mov    %esp,%ebp
80102fce:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fd1:	e8 6b fe ff ff       	call   80102e41 <readeflags>
80102fd6:	25 00 02 00 00       	and    $0x200,%eax
80102fdb:	85 c0                	test   %eax,%eax
80102fdd:	74 25                	je     80103004 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102fdf:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102fe4:	8d 50 01             	lea    0x1(%eax),%edx
80102fe7:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
80102fed:	85 c0                	test   %eax,%eax
80102fef:	75 13                	jne    80103004 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102ff1:	8b 45 04             	mov    0x4(%ebp),%eax
80102ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ff8:	c7 04 24 20 8b 10 80 	movl   $0x80108b20,(%esp)
80102fff:	e8 ff d3 ff ff       	call   80100403 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80103004:	a1 3c 2c 11 80       	mov    0x80112c3c,%eax
80103009:	85 c0                	test   %eax,%eax
8010300b:	74 0f                	je     8010301c <cpunum+0x51>
    return lapic[ID]>>24;
8010300d:	a1 3c 2c 11 80       	mov    0x80112c3c,%eax
80103012:	83 c0 20             	add    $0x20,%eax
80103015:	8b 00                	mov    (%eax),%eax
80103017:	c1 e8 18             	shr    $0x18,%eax
8010301a:	eb 05                	jmp    80103021 <cpunum+0x56>
  return 0;
8010301c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103021:	c9                   	leave  
80103022:	c3                   	ret    

80103023 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103023:	55                   	push   %ebp
80103024:	89 e5                	mov    %esp,%ebp
80103026:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103029:	a1 3c 2c 11 80       	mov    0x80112c3c,%eax
8010302e:	85 c0                	test   %eax,%eax
80103030:	74 14                	je     80103046 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103032:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103039:	00 
8010303a:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103041:	e8 0b fe ff ff       	call   80102e51 <lapicw>
}
80103046:	c9                   	leave  
80103047:	c3                   	ret    

80103048 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103048:	55                   	push   %ebp
80103049:	89 e5                	mov    %esp,%ebp
}
8010304b:	5d                   	pop    %ebp
8010304c:	c3                   	ret    

8010304d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010304d:	55                   	push   %ebp
8010304e:	89 e5                	mov    %esp,%ebp
80103050:	83 ec 1c             	sub    $0x1c,%esp
80103053:	8b 45 08             	mov    0x8(%ebp),%eax
80103056:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103059:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103060:	00 
80103061:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103068:	e8 b6 fd ff ff       	call   80102e23 <outb>
  outb(CMOS_PORT+1, 0x0A);
8010306d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103074:	00 
80103075:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010307c:	e8 a2 fd ff ff       	call   80102e23 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103081:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103088:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010308b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103090:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103093:	8d 50 02             	lea    0x2(%eax),%edx
80103096:	8b 45 0c             	mov    0xc(%ebp),%eax
80103099:	c1 e8 04             	shr    $0x4,%eax
8010309c:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010309f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030a3:	c1 e0 18             	shl    $0x18,%eax
801030a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801030aa:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030b1:	e8 9b fd ff ff       	call   80102e51 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030b6:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801030bd:	00 
801030be:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030c5:	e8 87 fd ff ff       	call   80102e51 <lapicw>
  microdelay(200);
801030ca:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030d1:	e8 72 ff ff ff       	call   80103048 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801030d6:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801030dd:	00 
801030de:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030e5:	e8 67 fd ff ff       	call   80102e51 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ea:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801030f1:	e8 52 ff ff ff       	call   80103048 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030fd:	eb 40                	jmp    8010313f <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801030ff:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103103:	c1 e0 18             	shl    $0x18,%eax
80103106:	89 44 24 04          	mov    %eax,0x4(%esp)
8010310a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103111:	e8 3b fd ff ff       	call   80102e51 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103116:	8b 45 0c             	mov    0xc(%ebp),%eax
80103119:	c1 e8 0c             	shr    $0xc,%eax
8010311c:	80 cc 06             	or     $0x6,%ah
8010311f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103123:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010312a:	e8 22 fd ff ff       	call   80102e51 <lapicw>
    microdelay(200);
8010312f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103136:	e8 0d ff ff ff       	call   80103048 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010313b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010313f:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103143:	7e ba                	jle    801030ff <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103145:	c9                   	leave  
80103146:	c3                   	ret    

80103147 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103147:	55                   	push   %ebp
80103148:	89 e5                	mov    %esp,%ebp
8010314a:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
8010314d:	8b 45 08             	mov    0x8(%ebp),%eax
80103150:	0f b6 c0             	movzbl %al,%eax
80103153:	89 44 24 04          	mov    %eax,0x4(%esp)
80103157:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010315e:	e8 c0 fc ff ff       	call   80102e23 <outb>
  microdelay(200);
80103163:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010316a:	e8 d9 fe ff ff       	call   80103048 <microdelay>

  return inb(CMOS_RETURN);
8010316f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103176:	e8 8b fc ff ff       	call   80102e06 <inb>
8010317b:	0f b6 c0             	movzbl %al,%eax
}
8010317e:	c9                   	leave  
8010317f:	c3                   	ret    

80103180 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103180:	55                   	push   %ebp
80103181:	89 e5                	mov    %esp,%ebp
80103183:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103186:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010318d:	e8 b5 ff ff ff       	call   80103147 <cmos_read>
80103192:	8b 55 08             	mov    0x8(%ebp),%edx
80103195:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103197:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010319e:	e8 a4 ff ff ff       	call   80103147 <cmos_read>
801031a3:	8b 55 08             	mov    0x8(%ebp),%edx
801031a6:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801031a9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801031b0:	e8 92 ff ff ff       	call   80103147 <cmos_read>
801031b5:	8b 55 08             	mov    0x8(%ebp),%edx
801031b8:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801031bb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801031c2:	e8 80 ff ff ff       	call   80103147 <cmos_read>
801031c7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ca:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031cd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801031d4:	e8 6e ff ff ff       	call   80103147 <cmos_read>
801031d9:	8b 55 08             	mov    0x8(%ebp),%edx
801031dc:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031df:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801031e6:	e8 5c ff ff ff       	call   80103147 <cmos_read>
801031eb:	8b 55 08             	mov    0x8(%ebp),%edx
801031ee:	89 42 14             	mov    %eax,0x14(%edx)
}
801031f1:	c9                   	leave  
801031f2:	c3                   	ret    

801031f3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031f3:	55                   	push   %ebp
801031f4:	89 e5                	mov    %esp,%ebp
801031f6:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031f9:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103200:	e8 42 ff ff ff       	call   80103147 <cmos_read>
80103205:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010320b:	83 e0 04             	and    $0x4,%eax
8010320e:	85 c0                	test   %eax,%eax
80103210:	0f 94 c0             	sete   %al
80103213:	0f b6 c0             	movzbl %al,%eax
80103216:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103219:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010321c:	89 04 24             	mov    %eax,(%esp)
8010321f:	e8 5c ff ff ff       	call   80103180 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103224:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010322b:	e8 17 ff ff ff       	call   80103147 <cmos_read>
80103230:	25 80 00 00 00       	and    $0x80,%eax
80103235:	85 c0                	test   %eax,%eax
80103237:	74 02                	je     8010323b <cmostime+0x48>
        continue;
80103239:	eb 36                	jmp    80103271 <cmostime+0x7e>
    fill_rtcdate(&t2);
8010323b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010323e:	89 04 24             	mov    %eax,(%esp)
80103241:	e8 3a ff ff ff       	call   80103180 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103246:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010324d:	00 
8010324e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103251:	89 44 24 04          	mov    %eax,0x4(%esp)
80103255:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103258:	89 04 24             	mov    %eax,(%esp)
8010325b:	e8 b6 20 00 00       	call   80105316 <memcmp>
80103260:	85 c0                	test   %eax,%eax
80103262:	75 0d                	jne    80103271 <cmostime+0x7e>
      break;
80103264:	90                   	nop
  }

  // convert
  if (bcd) {
80103265:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103269:	0f 84 ac 00 00 00    	je     8010331b <cmostime+0x128>
8010326f:	eb 02                	jmp    80103273 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103271:	eb a6                	jmp    80103219 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103273:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103276:	c1 e8 04             	shr    $0x4,%eax
80103279:	89 c2                	mov    %eax,%edx
8010327b:	89 d0                	mov    %edx,%eax
8010327d:	c1 e0 02             	shl    $0x2,%eax
80103280:	01 d0                	add    %edx,%eax
80103282:	01 c0                	add    %eax,%eax
80103284:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103287:	83 e2 0f             	and    $0xf,%edx
8010328a:	01 d0                	add    %edx,%eax
8010328c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010328f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103292:	c1 e8 04             	shr    $0x4,%eax
80103295:	89 c2                	mov    %eax,%edx
80103297:	89 d0                	mov    %edx,%eax
80103299:	c1 e0 02             	shl    $0x2,%eax
8010329c:	01 d0                	add    %edx,%eax
8010329e:	01 c0                	add    %eax,%eax
801032a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032a3:	83 e2 0f             	and    $0xf,%edx
801032a6:	01 d0                	add    %edx,%eax
801032a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801032ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032ae:	c1 e8 04             	shr    $0x4,%eax
801032b1:	89 c2                	mov    %eax,%edx
801032b3:	89 d0                	mov    %edx,%eax
801032b5:	c1 e0 02             	shl    $0x2,%eax
801032b8:	01 d0                	add    %edx,%eax
801032ba:	01 c0                	add    %eax,%eax
801032bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032bf:	83 e2 0f             	and    $0xf,%edx
801032c2:	01 d0                	add    %edx,%eax
801032c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032ca:	c1 e8 04             	shr    $0x4,%eax
801032cd:	89 c2                	mov    %eax,%edx
801032cf:	89 d0                	mov    %edx,%eax
801032d1:	c1 e0 02             	shl    $0x2,%eax
801032d4:	01 d0                	add    %edx,%eax
801032d6:	01 c0                	add    %eax,%eax
801032d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032db:	83 e2 0f             	and    $0xf,%edx
801032de:	01 d0                	add    %edx,%eax
801032e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032e6:	c1 e8 04             	shr    $0x4,%eax
801032e9:	89 c2                	mov    %eax,%edx
801032eb:	89 d0                	mov    %edx,%eax
801032ed:	c1 e0 02             	shl    $0x2,%eax
801032f0:	01 d0                	add    %edx,%eax
801032f2:	01 c0                	add    %eax,%eax
801032f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032f7:	83 e2 0f             	and    $0xf,%edx
801032fa:	01 d0                	add    %edx,%eax
801032fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103302:	c1 e8 04             	shr    $0x4,%eax
80103305:	89 c2                	mov    %eax,%edx
80103307:	89 d0                	mov    %edx,%eax
80103309:	c1 e0 02             	shl    $0x2,%eax
8010330c:	01 d0                	add    %edx,%eax
8010330e:	01 c0                	add    %eax,%eax
80103310:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103313:	83 e2 0f             	and    $0xf,%edx
80103316:	01 d0                	add    %edx,%eax
80103318:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010331b:	8b 45 08             	mov    0x8(%ebp),%eax
8010331e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103321:	89 10                	mov    %edx,(%eax)
80103323:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103326:	89 50 04             	mov    %edx,0x4(%eax)
80103329:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010332c:	89 50 08             	mov    %edx,0x8(%eax)
8010332f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103332:	89 50 0c             	mov    %edx,0xc(%eax)
80103335:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103338:	89 50 10             	mov    %edx,0x10(%eax)
8010333b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010333e:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	8b 40 14             	mov    0x14(%eax),%eax
80103347:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010334d:	8b 45 08             	mov    0x8(%ebp),%eax
80103350:	89 50 14             	mov    %edx,0x14(%eax)
}
80103353:	c9                   	leave  
80103354:	c3                   	ret    

80103355 <unixtime>:

// This is not the "real" UNIX time as it makes many
// simplifying assumptions -- no leap years, months
// that are all the same length (!)
unsigned long unixtime(void) {
80103355:	55                   	push   %ebp
80103356:	89 e5                	mov    %esp,%ebp
80103358:	83 ec 38             	sub    $0x38,%esp
  struct rtcdate t;
  cmostime(&t);
8010335b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010335e:	89 04 24             	mov    %eax,(%esp)
80103361:	e8 8d fe ff ff       	call   801031f3 <cmostime>
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	69 d0 80 33 e1 01    	imul   $0x1e13380,%eax,%edx
         (t.month * 30 * 24 * 60 * 60) +
8010336f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103372:	69 c0 00 8d 27 00    	imul   $0x278d00,%eax,%eax
// simplifying assumptions -- no leap years, months
// that are all the same length (!)
unsigned long unixtime(void) {
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
80103378:	01 c2                	add    %eax,%edx
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
8010337a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337d:	69 c0 80 51 01 00    	imul   $0x15180,%eax,%eax
// that are all the same length (!)
unsigned long unixtime(void) {
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
         (t.month * 30 * 24 * 60 * 60) +
80103383:	01 c2                	add    %eax,%edx
         (t.day * 24 * 60 * 60) +
         (t.hour * 60 * 60) +
80103385:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103388:	69 c0 10 0e 00 00    	imul   $0xe10,%eax,%eax
unsigned long unixtime(void) {
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
8010338e:	01 c2                	add    %eax,%edx
         (t.hour * 60 * 60) +
         (t.minute * 60) +
80103390:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103393:	c1 e0 02             	shl    $0x2,%eax
80103396:	89 c1                	mov    %eax,%ecx
80103398:	c1 e1 04             	shl    $0x4,%ecx
8010339b:	29 c1                	sub    %eax,%ecx
8010339d:	89 c8                	mov    %ecx,%eax
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
         (t.hour * 60 * 60) +
8010339f:	01 c2                	add    %eax,%edx
         (t.minute * 60) +
         (t.second);
801033a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
         (t.hour * 60 * 60) +
         (t.minute * 60) +
801033a4:	01 d0                	add    %edx,%eax
// simplifying assumptions -- no leap years, months
// that are all the same length (!)
unsigned long unixtime(void) {
  struct rtcdate t;
  cmostime(&t);
  return ((t.year - 1970) * 365 * 24 * 60 * 60) +
801033a6:	2d 00 4f fe 76       	sub    $0x76fe4f00,%eax
         (t.month * 30 * 24 * 60 * 60) +
         (t.day * 24 * 60 * 60) +
         (t.hour * 60 * 60) +
         (t.minute * 60) +
         (t.second);
}
801033ab:	c9                   	leave  
801033ac:	c3                   	ret    

801033ad <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033ad:	55                   	push   %ebp
801033ae:	89 e5                	mov    %esp,%ebp
801033b0:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033b3:	c7 44 24 04 4c 8b 10 	movl   $0x80108b4c,0x4(%esp)
801033ba:	80 
801033bb:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
801033c2:	e8 63 1c 00 00       	call   8010502a <initlock>
  readsb(dev, &sb);
801033c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801033ce:	8b 45 08             	mov    0x8(%ebp),%eax
801033d1:	89 04 24             	mov    %eax,(%esp)
801033d4:	e8 d0 df ff ff       	call   801013a9 <readsb>
  log.start = sb.logstart;
801033d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033dc:	a3 74 2c 11 80       	mov    %eax,0x80112c74
  log.size = sb.nlog;
801033e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033e4:	a3 78 2c 11 80       	mov    %eax,0x80112c78
  log.dev = dev;
801033e9:	8b 45 08             	mov    0x8(%ebp),%eax
801033ec:	a3 84 2c 11 80       	mov    %eax,0x80112c84
  recover_from_log();
801033f1:	e8 9a 01 00 00       	call   80103590 <recover_from_log>
}
801033f6:	c9                   	leave  
801033f7:	c3                   	ret    

801033f8 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033f8:	55                   	push   %ebp
801033f9:	89 e5                	mov    %esp,%ebp
801033fb:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103405:	e9 8c 00 00 00       	jmp    80103496 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010340a:	8b 15 74 2c 11 80    	mov    0x80112c74,%edx
80103410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103413:	01 d0                	add    %edx,%eax
80103415:	83 c0 01             	add    $0x1,%eax
80103418:	89 c2                	mov    %eax,%edx
8010341a:	a1 84 2c 11 80       	mov    0x80112c84,%eax
8010341f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103423:	89 04 24             	mov    %eax,(%esp)
80103426:	e8 7b cd ff ff       	call   801001a6 <bread>
8010342b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103431:	83 c0 10             	add    $0x10,%eax
80103434:	8b 04 85 4c 2c 11 80 	mov    -0x7feed3b4(,%eax,4),%eax
8010343b:	89 c2                	mov    %eax,%edx
8010343d:	a1 84 2c 11 80       	mov    0x80112c84,%eax
80103442:	89 54 24 04          	mov    %edx,0x4(%esp)
80103446:	89 04 24             	mov    %eax,(%esp)
80103449:	e8 58 cd ff ff       	call   801001a6 <bread>
8010344e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103454:	8d 50 18             	lea    0x18(%eax),%edx
80103457:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345a:	83 c0 18             	add    $0x18,%eax
8010345d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103464:	00 
80103465:	89 54 24 04          	mov    %edx,0x4(%esp)
80103469:	89 04 24             	mov    %eax,(%esp)
8010346c:	e8 fd 1e 00 00       	call   8010536e <memmove>
    bwrite(dbuf);  // write dst to disk
80103471:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103474:	89 04 24             	mov    %eax,(%esp)
80103477:	e8 61 cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010347c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347f:	89 04 24             	mov    %eax,(%esp)
80103482:	e8 90 cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103487:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010348a:	89 04 24             	mov    %eax,(%esp)
8010348d:	e8 85 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103492:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103496:	a1 88 2c 11 80       	mov    0x80112c88,%eax
8010349b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010349e:	0f 8f 66 ff ff ff    	jg     8010340a <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801034a4:	c9                   	leave  
801034a5:	c3                   	ret    

801034a6 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034a6:	55                   	push   %ebp
801034a7:	89 e5                	mov    %esp,%ebp
801034a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ac:	a1 74 2c 11 80       	mov    0x80112c74,%eax
801034b1:	89 c2                	mov    %eax,%edx
801034b3:	a1 84 2c 11 80       	mov    0x80112c84,%eax
801034b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801034bc:	89 04 24             	mov    %eax,(%esp)
801034bf:	e8 e2 cc ff ff       	call   801001a6 <bread>
801034c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ca:	83 c0 18             	add    $0x18,%eax
801034cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d3:	8b 00                	mov    (%eax),%eax
801034d5:	a3 88 2c 11 80       	mov    %eax,0x80112c88
  for (i = 0; i < log.lh.n; i++) {
801034da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e1:	eb 1b                	jmp    801034fe <read_head+0x58>
    log.lh.block[i] = lh->block[i];
801034e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034e9:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034f0:	83 c2 10             	add    $0x10,%edx
801034f3:	89 04 95 4c 2c 11 80 	mov    %eax,-0x7feed3b4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034fe:	a1 88 2c 11 80       	mov    0x80112c88,%eax
80103503:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103506:	7f db                	jg     801034e3 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010350b:	89 04 24             	mov    %eax,(%esp)
8010350e:	e8 04 cd ff ff       	call   80100217 <brelse>
}
80103513:	c9                   	leave  
80103514:	c3                   	ret    

80103515 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103515:	55                   	push   %ebp
80103516:	89 e5                	mov    %esp,%ebp
80103518:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010351b:	a1 74 2c 11 80       	mov    0x80112c74,%eax
80103520:	89 c2                	mov    %eax,%edx
80103522:	a1 84 2c 11 80       	mov    0x80112c84,%eax
80103527:	89 54 24 04          	mov    %edx,0x4(%esp)
8010352b:	89 04 24             	mov    %eax,(%esp)
8010352e:	e8 73 cc ff ff       	call   801001a6 <bread>
80103533:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103536:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103539:	83 c0 18             	add    $0x18,%eax
8010353c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010353f:	8b 15 88 2c 11 80    	mov    0x80112c88,%edx
80103545:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103548:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010354a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103551:	eb 1b                	jmp    8010356e <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103556:	83 c0 10             	add    $0x10,%eax
80103559:	8b 0c 85 4c 2c 11 80 	mov    -0x7feed3b4(,%eax,4),%ecx
80103560:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103563:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103566:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010356a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010356e:	a1 88 2c 11 80       	mov    0x80112c88,%eax
80103573:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103576:	7f db                	jg     80103553 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010357b:	89 04 24             	mov    %eax,(%esp)
8010357e:	e8 5a cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103583:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103586:	89 04 24             	mov    %eax,(%esp)
80103589:	e8 89 cc ff ff       	call   80100217 <brelse>
}
8010358e:	c9                   	leave  
8010358f:	c3                   	ret    

80103590 <recover_from_log>:

static void
recover_from_log(void)
{
80103590:	55                   	push   %ebp
80103591:	89 e5                	mov    %esp,%ebp
80103593:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103596:	e8 0b ff ff ff       	call   801034a6 <read_head>
  install_trans(); // if committed, copy from log to disk
8010359b:	e8 58 fe ff ff       	call   801033f8 <install_trans>
  log.lh.n = 0;
801035a0:	c7 05 88 2c 11 80 00 	movl   $0x0,0x80112c88
801035a7:	00 00 00 
  write_head(); // clear the log
801035aa:	e8 66 ff ff ff       	call   80103515 <write_head>
}
801035af:	c9                   	leave  
801035b0:	c3                   	ret    

801035b1 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035b1:	55                   	push   %ebp
801035b2:	89 e5                	mov    %esp,%ebp
801035b4:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801035b7:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
801035be:	e8 88 1a 00 00       	call   8010504b <acquire>
  while(1){
    if(log.committing){
801035c3:	a1 80 2c 11 80       	mov    0x80112c80,%eax
801035c8:	85 c0                	test   %eax,%eax
801035ca:	74 16                	je     801035e2 <begin_op+0x31>
      sleep(&log, &log.lock);
801035cc:	c7 44 24 04 40 2c 11 	movl   $0x80112c40,0x4(%esp)
801035d3:	80 
801035d4:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
801035db:	e8 97 17 00 00       	call   80104d77 <sleep>
801035e0:	eb 4f                	jmp    80103631 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035e2:	8b 0d 88 2c 11 80    	mov    0x80112c88,%ecx
801035e8:	a1 7c 2c 11 80       	mov    0x80112c7c,%eax
801035ed:	8d 50 01             	lea    0x1(%eax),%edx
801035f0:	89 d0                	mov    %edx,%eax
801035f2:	c1 e0 02             	shl    $0x2,%eax
801035f5:	01 d0                	add    %edx,%eax
801035f7:	01 c0                	add    %eax,%eax
801035f9:	01 c8                	add    %ecx,%eax
801035fb:	83 f8 1e             	cmp    $0x1e,%eax
801035fe:	7e 16                	jle    80103616 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103600:	c7 44 24 04 40 2c 11 	movl   $0x80112c40,0x4(%esp)
80103607:	80 
80103608:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
8010360f:	e8 63 17 00 00       	call   80104d77 <sleep>
80103614:	eb 1b                	jmp    80103631 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103616:	a1 7c 2c 11 80       	mov    0x80112c7c,%eax
8010361b:	83 c0 01             	add    $0x1,%eax
8010361e:	a3 7c 2c 11 80       	mov    %eax,0x80112c7c
      release(&log.lock);
80103623:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
8010362a:	e8 7e 1a 00 00       	call   801050ad <release>
      break;
8010362f:	eb 02                	jmp    80103633 <begin_op+0x82>
    }
  }
80103631:	eb 90                	jmp    801035c3 <begin_op+0x12>
}
80103633:	c9                   	leave  
80103634:	c3                   	ret    

80103635 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103635:	55                   	push   %ebp
80103636:	89 e5                	mov    %esp,%ebp
80103638:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010363b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103642:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
80103649:	e8 fd 19 00 00       	call   8010504b <acquire>
  log.outstanding -= 1;
8010364e:	a1 7c 2c 11 80       	mov    0x80112c7c,%eax
80103653:	83 e8 01             	sub    $0x1,%eax
80103656:	a3 7c 2c 11 80       	mov    %eax,0x80112c7c
  if(log.committing)
8010365b:	a1 80 2c 11 80       	mov    0x80112c80,%eax
80103660:	85 c0                	test   %eax,%eax
80103662:	74 0c                	je     80103670 <end_op+0x3b>
    panic("log.committing");
80103664:	c7 04 24 50 8b 10 80 	movl   $0x80108b50,(%esp)
8010366b:	e8 67 cf ff ff       	call   801005d7 <panic>
  if(log.outstanding == 0){
80103670:	a1 7c 2c 11 80       	mov    0x80112c7c,%eax
80103675:	85 c0                	test   %eax,%eax
80103677:	75 13                	jne    8010368c <end_op+0x57>
    do_commit = 1;
80103679:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103680:	c7 05 80 2c 11 80 01 	movl   $0x1,0x80112c80
80103687:	00 00 00 
8010368a:	eb 0c                	jmp    80103698 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010368c:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
80103693:	e8 b8 17 00 00       	call   80104e50 <wakeup>
  }
  release(&log.lock);
80103698:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
8010369f:	e8 09 1a 00 00       	call   801050ad <release>

  if(do_commit){
801036a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036a8:	74 33                	je     801036dd <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036aa:	e8 de 00 00 00       	call   8010378d <commit>
    acquire(&log.lock);
801036af:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
801036b6:	e8 90 19 00 00       	call   8010504b <acquire>
    log.committing = 0;
801036bb:	c7 05 80 2c 11 80 00 	movl   $0x0,0x80112c80
801036c2:	00 00 00 
    wakeup(&log);
801036c5:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
801036cc:	e8 7f 17 00 00       	call   80104e50 <wakeup>
    release(&log.lock);
801036d1:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
801036d8:	e8 d0 19 00 00       	call   801050ad <release>
  }
}
801036dd:	c9                   	leave  
801036de:	c3                   	ret    

801036df <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036df:	55                   	push   %ebp
801036e0:	89 e5                	mov    %esp,%ebp
801036e2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036ec:	e9 8c 00 00 00       	jmp    8010377d <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036f1:	8b 15 74 2c 11 80    	mov    0x80112c74,%edx
801036f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036fa:	01 d0                	add    %edx,%eax
801036fc:	83 c0 01             	add    $0x1,%eax
801036ff:	89 c2                	mov    %eax,%edx
80103701:	a1 84 2c 11 80       	mov    0x80112c84,%eax
80103706:	89 54 24 04          	mov    %edx,0x4(%esp)
8010370a:	89 04 24             	mov    %eax,(%esp)
8010370d:	e8 94 ca ff ff       	call   801001a6 <bread>
80103712:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103718:	83 c0 10             	add    $0x10,%eax
8010371b:	8b 04 85 4c 2c 11 80 	mov    -0x7feed3b4(,%eax,4),%eax
80103722:	89 c2                	mov    %eax,%edx
80103724:	a1 84 2c 11 80       	mov    0x80112c84,%eax
80103729:	89 54 24 04          	mov    %edx,0x4(%esp)
8010372d:	89 04 24             	mov    %eax,(%esp)
80103730:	e8 71 ca ff ff       	call   801001a6 <bread>
80103735:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103738:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010373b:	8d 50 18             	lea    0x18(%eax),%edx
8010373e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103741:	83 c0 18             	add    $0x18,%eax
80103744:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010374b:	00 
8010374c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103750:	89 04 24             	mov    %eax,(%esp)
80103753:	e8 16 1c 00 00       	call   8010536e <memmove>
    bwrite(to);  // write the log
80103758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010375b:	89 04 24             	mov    %eax,(%esp)
8010375e:	e8 7a ca ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103763:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103766:	89 04 24             	mov    %eax,(%esp)
80103769:	e8 a9 ca ff ff       	call   80100217 <brelse>
    brelse(to);
8010376e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103771:	89 04 24             	mov    %eax,(%esp)
80103774:	e8 9e ca ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103779:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010377d:	a1 88 2c 11 80       	mov    0x80112c88,%eax
80103782:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103785:	0f 8f 66 ff ff ff    	jg     801036f1 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
8010378b:	c9                   	leave  
8010378c:	c3                   	ret    

8010378d <commit>:

static void
commit()
{
8010378d:	55                   	push   %ebp
8010378e:	89 e5                	mov    %esp,%ebp
80103790:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103793:	a1 88 2c 11 80       	mov    0x80112c88,%eax
80103798:	85 c0                	test   %eax,%eax
8010379a:	7e 1e                	jle    801037ba <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010379c:	e8 3e ff ff ff       	call   801036df <write_log>
    write_head();    // Write header to disk -- the real commit
801037a1:	e8 6f fd ff ff       	call   80103515 <write_head>
    install_trans(); // Now install writes to home locations
801037a6:	e8 4d fc ff ff       	call   801033f8 <install_trans>
    log.lh.n = 0; 
801037ab:	c7 05 88 2c 11 80 00 	movl   $0x0,0x80112c88
801037b2:	00 00 00 
    write_head();    // Erase the transaction from the log
801037b5:	e8 5b fd ff ff       	call   80103515 <write_head>
  }
}
801037ba:	c9                   	leave  
801037bb:	c3                   	ret    

801037bc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037bc:	55                   	push   %ebp
801037bd:	89 e5                	mov    %esp,%ebp
801037bf:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037c2:	a1 88 2c 11 80       	mov    0x80112c88,%eax
801037c7:	83 f8 1d             	cmp    $0x1d,%eax
801037ca:	7f 12                	jg     801037de <log_write+0x22>
801037cc:	a1 88 2c 11 80       	mov    0x80112c88,%eax
801037d1:	8b 15 78 2c 11 80    	mov    0x80112c78,%edx
801037d7:	83 ea 01             	sub    $0x1,%edx
801037da:	39 d0                	cmp    %edx,%eax
801037dc:	7c 0c                	jl     801037ea <log_write+0x2e>
    panic("too big a transaction");
801037de:	c7 04 24 5f 8b 10 80 	movl   $0x80108b5f,(%esp)
801037e5:	e8 ed cd ff ff       	call   801005d7 <panic>
  if (log.outstanding < 1)
801037ea:	a1 7c 2c 11 80       	mov    0x80112c7c,%eax
801037ef:	85 c0                	test   %eax,%eax
801037f1:	7f 0c                	jg     801037ff <log_write+0x43>
    panic("log_write outside of trans");
801037f3:	c7 04 24 75 8b 10 80 	movl   $0x80108b75,(%esp)
801037fa:	e8 d8 cd ff ff       	call   801005d7 <panic>

  acquire(&log.lock);
801037ff:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
80103806:	e8 40 18 00 00       	call   8010504b <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010380b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103812:	eb 1f                	jmp    80103833 <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103817:	83 c0 10             	add    $0x10,%eax
8010381a:	8b 04 85 4c 2c 11 80 	mov    -0x7feed3b4(,%eax,4),%eax
80103821:	89 c2                	mov    %eax,%edx
80103823:	8b 45 08             	mov    0x8(%ebp),%eax
80103826:	8b 40 08             	mov    0x8(%eax),%eax
80103829:	39 c2                	cmp    %eax,%edx
8010382b:	75 02                	jne    8010382f <log_write+0x73>
      break;
8010382d:	eb 0e                	jmp    8010383d <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010382f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103833:	a1 88 2c 11 80       	mov    0x80112c88,%eax
80103838:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010383b:	7f d7                	jg     80103814 <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
8010383d:	8b 45 08             	mov    0x8(%ebp),%eax
80103840:	8b 40 08             	mov    0x8(%eax),%eax
80103843:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103846:	83 c2 10             	add    $0x10,%edx
80103849:	89 04 95 4c 2c 11 80 	mov    %eax,-0x7feed3b4(,%edx,4)
  if (i == log.lh.n)
80103850:	a1 88 2c 11 80       	mov    0x80112c88,%eax
80103855:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103858:	75 0d                	jne    80103867 <log_write+0xab>
    log.lh.n++;
8010385a:	a1 88 2c 11 80       	mov    0x80112c88,%eax
8010385f:	83 c0 01             	add    $0x1,%eax
80103862:	a3 88 2c 11 80       	mov    %eax,0x80112c88
  b->flags |= B_DIRTY; // prevent eviction
80103867:	8b 45 08             	mov    0x8(%ebp),%eax
8010386a:	8b 00                	mov    (%eax),%eax
8010386c:	83 c8 04             	or     $0x4,%eax
8010386f:	89 c2                	mov    %eax,%edx
80103871:	8b 45 08             	mov    0x8(%ebp),%eax
80103874:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103876:	c7 04 24 40 2c 11 80 	movl   $0x80112c40,(%esp)
8010387d:	e8 2b 18 00 00       	call   801050ad <release>
}
80103882:	c9                   	leave  
80103883:	c3                   	ret    

80103884 <v2p>:
80103884:	55                   	push   %ebp
80103885:	89 e5                	mov    %esp,%ebp
80103887:	8b 45 08             	mov    0x8(%ebp),%eax
8010388a:	05 00 00 00 80       	add    $0x80000000,%eax
8010388f:	5d                   	pop    %ebp
80103890:	c3                   	ret    

80103891 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103891:	55                   	push   %ebp
80103892:	89 e5                	mov    %esp,%ebp
80103894:	8b 45 08             	mov    0x8(%ebp),%eax
80103897:	05 00 00 00 80       	add    $0x80000000,%eax
8010389c:	5d                   	pop    %ebp
8010389d:	c3                   	ret    

8010389e <xchg>:
    return ret;
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010389e:	55                   	push   %ebp
8010389f:	89 e5                	mov    %esp,%ebp
801038a1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038a4:	8b 55 08             	mov    0x8(%ebp),%edx
801038a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801038aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038ad:	f0 87 02             	lock xchg %eax,(%edx)
801038b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038b6:	c9                   	leave  
801038b7:	c3                   	ret    

801038b8 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038b8:	55                   	push   %ebp
801038b9:	89 e5                	mov    %esp,%ebp
801038bb:	83 e4 f0             	and    $0xfffffff0,%esp
801038be:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038c1:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801038c8:	80 
801038c9:	c7 04 24 1c 5c 11 80 	movl   $0x80115c1c,(%esp)
801038d0:	e8 32 f2 ff ff       	call   80102b07 <kinit1>
  kvmalloc();      // kernel page table
801038d5:	e8 47 48 00 00       	call   80108121 <kvmalloc>
  mpinit();        // collect info about this machine
801038da:	e8 41 04 00 00       	call   80103d20 <mpinit>
  lapicinit();
801038df:	e8 8e f5 ff ff       	call   80102e72 <lapicinit>
  seginit();       // set up segments
801038e4:	e8 cb 41 00 00       	call   80107ab4 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038e9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038ef:	0f b6 00             	movzbl (%eax),%eax
801038f2:	0f b6 c0             	movzbl %al,%eax
801038f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801038f9:	c7 04 24 90 8b 10 80 	movl   $0x80108b90,(%esp)
80103900:	e8 fe ca ff ff       	call   80100403 <cprintf>
  picinit();       // interrupt controller
80103905:	e8 74 06 00 00       	call   80103f7e <picinit>
  ioapicinit();    // another interrupt controller
8010390a:	e8 ee f0 ff ff       	call   801029fd <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010390f:	e8 39 d2 ff ff       	call   80100b4d <consoleinit>
  uartinit();      // serial port
80103914:	e8 aa 32 00 00       	call   80106bc3 <uartinit>
  pinit();         // process table
80103919:	e8 70 0b 00 00       	call   8010448e <pinit>
  tvinit();        // trap vectors
8010391e:	e8 52 2e 00 00       	call   80106775 <tvinit>
  binit();         // buffer cache
80103923:	e8 0c c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103928:	e8 95 d6 ff ff       	call   80100fc2 <fileinit>
  ideinit();       // disk
8010392d:	e8 fd ec ff ff       	call   8010262f <ideinit>
  if(!ismp)
80103932:	a1 24 2d 11 80       	mov    0x80112d24,%eax
80103937:	85 c0                	test   %eax,%eax
80103939:	75 05                	jne    80103940 <main+0x88>
    timerinit();   // uniprocessor timer
8010393b:	e8 80 2d 00 00       	call   801066c0 <timerinit>
  startothers();   // start other processors
80103940:	e8 7f 00 00 00       	call   801039c4 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103945:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010394c:	8e 
8010394d:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103954:	e8 e6 f1 ff ff       	call   80102b3f <kinit2>
  userinit();      // first user process
80103959:	e8 62 0c 00 00       	call   801045c0 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010395e:	e8 1a 00 00 00       	call   8010397d <mpmain>

80103963 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103963:	55                   	push   %ebp
80103964:	89 e5                	mov    %esp,%ebp
80103966:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103969:	e8 ca 47 00 00       	call   80108138 <switchkvm>
  seginit();
8010396e:	e8 41 41 00 00       	call   80107ab4 <seginit>
  lapicinit();
80103973:	e8 fa f4 ff ff       	call   80102e72 <lapicinit>
  mpmain();
80103978:	e8 00 00 00 00       	call   8010397d <mpmain>

8010397d <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010397d:	55                   	push   %ebp
8010397e:	89 e5                	mov    %esp,%ebp
80103980:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103983:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103989:	0f b6 00             	movzbl (%eax),%eax
8010398c:	0f b6 c0             	movzbl %al,%eax
8010398f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103993:	c7 04 24 a7 8b 10 80 	movl   $0x80108ba7,(%esp)
8010399a:	e8 64 ca ff ff       	call   80100403 <cprintf>
  idtinit();       // load idt register
8010399f:	e8 45 2f 00 00       	call   801068e9 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801039a4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039aa:	05 a8 00 00 00       	add    $0xa8,%eax
801039af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801039b6:	00 
801039b7:	89 04 24             	mov    %eax,(%esp)
801039ba:	e8 df fe ff ff       	call   8010389e <xchg>
  scheduler();     // start running processes
801039bf:	e8 6d 11 00 00       	call   80104b31 <scheduler>

801039c4 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039c4:	55                   	push   %ebp
801039c5:	89 e5                	mov    %esp,%ebp
801039c7:	53                   	push   %ebx
801039c8:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039cb:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801039d2:	e8 ba fe ff ff       	call   80103891 <p2v>
801039d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039da:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039df:	89 44 24 08          	mov    %eax,0x8(%esp)
801039e3:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
801039ea:	80 
801039eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ee:	89 04 24             	mov    %eax,(%esp)
801039f1:	e8 78 19 00 00       	call   8010536e <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801039f6:	c7 45 f4 40 2d 11 80 	movl   $0x80112d40,-0xc(%ebp)
801039fd:	e9 85 00 00 00       	jmp    80103a87 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103a02:	e8 c4 f5 ff ff       	call   80102fcb <cpunum>
80103a07:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a0d:	05 40 2d 11 80       	add    $0x80112d40,%eax
80103a12:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a15:	75 02                	jne    80103a19 <startothers+0x55>
      continue;
80103a17:	eb 67                	jmp    80103a80 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a19:	e8 17 f2 ff ff       	call   80102c35 <kalloc>
80103a1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a24:	83 e8 04             	sub    $0x4,%eax
80103a27:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a2a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a30:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a35:	83 e8 08             	sub    $0x8,%eax
80103a38:	c7 00 63 39 10 80    	movl   $0x80103963,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a41:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a44:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103a4b:	e8 34 fe ff ff       	call   80103884 <v2p>
80103a50:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a55:	89 04 24             	mov    %eax,(%esp)
80103a58:	e8 27 fe ff ff       	call   80103884 <v2p>
80103a5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a60:	0f b6 12             	movzbl (%edx),%edx
80103a63:	0f b6 d2             	movzbl %dl,%edx
80103a66:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a6a:	89 14 24             	mov    %edx,(%esp)
80103a6d:	e8 db f5 ff ff       	call   8010304d <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a72:	90                   	nop
80103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a76:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a7c:	85 c0                	test   %eax,%eax
80103a7e:	74 f3                	je     80103a73 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a80:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a87:	a1 20 33 11 80       	mov    0x80113320,%eax
80103a8c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a92:	05 40 2d 11 80       	add    $0x80112d40,%eax
80103a97:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a9a:	0f 87 62 ff ff ff    	ja     80103a02 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103aa0:	83 c4 24             	add    $0x24,%esp
80103aa3:	5b                   	pop    %ebx
80103aa4:	5d                   	pop    %ebp
80103aa5:	c3                   	ret    

80103aa6 <p2v>:
80103aa6:	55                   	push   %ebp
80103aa7:	89 e5                	mov    %esp,%ebp
80103aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80103aac:	05 00 00 00 80       	add    $0x80000000,%eax
80103ab1:	5d                   	pop    %ebp
80103ab2:	c3                   	ret    

80103ab3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103ab3:	55                   	push   %ebp
80103ab4:	89 e5                	mov    %esp,%ebp
80103ab6:	83 ec 14             	sub    $0x14,%esp
80103ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80103abc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ac0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ac4:	89 c2                	mov    %eax,%edx
80103ac6:	ec                   	in     (%dx),%al
80103ac7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103aca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ace:	c9                   	leave  
80103acf:	c3                   	ret    

80103ad0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ad0:	55                   	push   %ebp
80103ad1:	89 e5                	mov    %esp,%ebp
80103ad3:	83 ec 08             	sub    $0x8,%esp
80103ad6:	8b 55 08             	mov    0x8(%ebp),%edx
80103ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103adc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ae0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ae3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ae7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103aeb:	ee                   	out    %al,(%dx)
}
80103aec:	c9                   	leave  
80103aed:	c3                   	ret    

80103aee <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103aee:	55                   	push   %ebp
80103aef:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103af1:	a1 64 b6 10 80       	mov    0x8010b664,%eax
80103af6:	89 c2                	mov    %eax,%edx
80103af8:	b8 40 2d 11 80       	mov    $0x80112d40,%eax
80103afd:	29 c2                	sub    %eax,%edx
80103aff:	89 d0                	mov    %edx,%eax
80103b01:	c1 f8 02             	sar    $0x2,%eax
80103b04:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b0a:	5d                   	pop    %ebp
80103b0b:	c3                   	ret    

80103b0c <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b0c:	55                   	push   %ebp
80103b0d:	89 e5                	mov    %esp,%ebp
80103b0f:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b12:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b20:	eb 15                	jmp    80103b37 <sum+0x2b>
    sum += addr[i];
80103b22:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b25:	8b 45 08             	mov    0x8(%ebp),%eax
80103b28:	01 d0                	add    %edx,%eax
80103b2a:	0f b6 00             	movzbl (%eax),%eax
80103b2d:	0f b6 c0             	movzbl %al,%eax
80103b30:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b33:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b3a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b3d:	7c e3                	jl     80103b22 <sum+0x16>
    sum += addr[i];
  return sum;
80103b3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b42:	c9                   	leave  
80103b43:	c3                   	ret    

80103b44 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b44:	55                   	push   %ebp
80103b45:	89 e5                	mov    %esp,%ebp
80103b47:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103b4d:	89 04 24             	mov    %eax,(%esp)
80103b50:	e8 51 ff ff ff       	call   80103aa6 <p2v>
80103b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b58:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5e:	01 d0                	add    %edx,%eax
80103b60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b66:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b69:	eb 3f                	jmp    80103baa <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b6b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b72:	00 
80103b73:	c7 44 24 04 b8 8b 10 	movl   $0x80108bb8,0x4(%esp)
80103b7a:	80 
80103b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7e:	89 04 24             	mov    %eax,(%esp)
80103b81:	e8 90 17 00 00       	call   80105316 <memcmp>
80103b86:	85 c0                	test   %eax,%eax
80103b88:	75 1c                	jne    80103ba6 <mpsearch1+0x62>
80103b8a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103b91:	00 
80103b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b95:	89 04 24             	mov    %eax,(%esp)
80103b98:	e8 6f ff ff ff       	call   80103b0c <sum>
80103b9d:	84 c0                	test   %al,%al
80103b9f:	75 05                	jne    80103ba6 <mpsearch1+0x62>
      return (struct mp*)p;
80103ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba4:	eb 11                	jmp    80103bb7 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ba6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bb0:	72 b9                	jb     80103b6b <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bb7:	c9                   	leave  
80103bb8:	c3                   	ret    

80103bb9 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bb9:	55                   	push   %ebp
80103bba:	89 e5                	mov    %esp,%ebp
80103bbc:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bbf:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc9:	83 c0 0f             	add    $0xf,%eax
80103bcc:	0f b6 00             	movzbl (%eax),%eax
80103bcf:	0f b6 c0             	movzbl %al,%eax
80103bd2:	c1 e0 08             	shl    $0x8,%eax
80103bd5:	89 c2                	mov    %eax,%edx
80103bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bda:	83 c0 0e             	add    $0xe,%eax
80103bdd:	0f b6 00             	movzbl (%eax),%eax
80103be0:	0f b6 c0             	movzbl %al,%eax
80103be3:	09 d0                	or     %edx,%eax
80103be5:	c1 e0 04             	shl    $0x4,%eax
80103be8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bef:	74 21                	je     80103c12 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bf1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103bf8:	00 
80103bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfc:	89 04 24             	mov    %eax,(%esp)
80103bff:	e8 40 ff ff ff       	call   80103b44 <mpsearch1>
80103c04:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c07:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c0b:	74 50                	je     80103c5d <mpsearch+0xa4>
      return mp;
80103c0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c10:	eb 5f                	jmp    80103c71 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c15:	83 c0 14             	add    $0x14,%eax
80103c18:	0f b6 00             	movzbl (%eax),%eax
80103c1b:	0f b6 c0             	movzbl %al,%eax
80103c1e:	c1 e0 08             	shl    $0x8,%eax
80103c21:	89 c2                	mov    %eax,%edx
80103c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c26:	83 c0 13             	add    $0x13,%eax
80103c29:	0f b6 00             	movzbl (%eax),%eax
80103c2c:	0f b6 c0             	movzbl %al,%eax
80103c2f:	09 d0                	or     %edx,%eax
80103c31:	c1 e0 0a             	shl    $0xa,%eax
80103c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3a:	2d 00 04 00 00       	sub    $0x400,%eax
80103c3f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c46:	00 
80103c47:	89 04 24             	mov    %eax,(%esp)
80103c4a:	e8 f5 fe ff ff       	call   80103b44 <mpsearch1>
80103c4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c52:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c56:	74 05                	je     80103c5d <mpsearch+0xa4>
      return mp;
80103c58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c5b:	eb 14                	jmp    80103c71 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c5d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103c64:	00 
80103c65:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103c6c:	e8 d3 fe ff ff       	call   80103b44 <mpsearch1>
}
80103c71:	c9                   	leave  
80103c72:	c3                   	ret    

80103c73 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c73:	55                   	push   %ebp
80103c74:	89 e5                	mov    %esp,%ebp
80103c76:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c79:	e8 3b ff ff ff       	call   80103bb9 <mpsearch>
80103c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c85:	74 0a                	je     80103c91 <mpconfig+0x1e>
80103c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8a:	8b 40 04             	mov    0x4(%eax),%eax
80103c8d:	85 c0                	test   %eax,%eax
80103c8f:	75 0a                	jne    80103c9b <mpconfig+0x28>
    return 0;
80103c91:	b8 00 00 00 00       	mov    $0x0,%eax
80103c96:	e9 83 00 00 00       	jmp    80103d1e <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9e:	8b 40 04             	mov    0x4(%eax),%eax
80103ca1:	89 04 24             	mov    %eax,(%esp)
80103ca4:	e8 fd fd ff ff       	call   80103aa6 <p2v>
80103ca9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cac:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103cb3:	00 
80103cb4:	c7 44 24 04 bd 8b 10 	movl   $0x80108bbd,0x4(%esp)
80103cbb:	80 
80103cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbf:	89 04 24             	mov    %eax,(%esp)
80103cc2:	e8 4f 16 00 00       	call   80105316 <memcmp>
80103cc7:	85 c0                	test   %eax,%eax
80103cc9:	74 07                	je     80103cd2 <mpconfig+0x5f>
    return 0;
80103ccb:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd0:	eb 4c                	jmp    80103d1e <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cd9:	3c 01                	cmp    $0x1,%al
80103cdb:	74 12                	je     80103cef <mpconfig+0x7c>
80103cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ce4:	3c 04                	cmp    $0x4,%al
80103ce6:	74 07                	je     80103cef <mpconfig+0x7c>
    return 0;
80103ce8:	b8 00 00 00 00       	mov    $0x0,%eax
80103ced:	eb 2f                	jmp    80103d1e <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cf6:	0f b7 c0             	movzwl %ax,%eax
80103cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d00:	89 04 24             	mov    %eax,(%esp)
80103d03:	e8 04 fe ff ff       	call   80103b0c <sum>
80103d08:	84 c0                	test   %al,%al
80103d0a:	74 07                	je     80103d13 <mpconfig+0xa0>
    return 0;
80103d0c:	b8 00 00 00 00       	mov    $0x0,%eax
80103d11:	eb 0b                	jmp    80103d1e <mpconfig+0xab>
  *pmp = mp;
80103d13:	8b 45 08             	mov    0x8(%ebp),%eax
80103d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d19:	89 10                	mov    %edx,(%eax)
  return conf;
80103d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d1e:	c9                   	leave  
80103d1f:	c3                   	ret    

80103d20 <mpinit>:

void
mpinit(void)
{
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d26:	c7 05 64 b6 10 80 40 	movl   $0x80112d40,0x8010b664
80103d2d:	2d 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d30:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d33:	89 04 24             	mov    %eax,(%esp)
80103d36:	e8 38 ff ff ff       	call   80103c73 <mpconfig>
80103d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d42:	75 05                	jne    80103d49 <mpinit+0x29>
    return;
80103d44:	e9 9c 01 00 00       	jmp    80103ee5 <mpinit+0x1c5>
  ismp = 1;
80103d49:	c7 05 24 2d 11 80 01 	movl   $0x1,0x80112d24
80103d50:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d56:	8b 40 24             	mov    0x24(%eax),%eax
80103d59:	a3 3c 2c 11 80       	mov    %eax,0x80112c3c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d61:	83 c0 2c             	add    $0x2c,%eax
80103d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d6a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d6e:	0f b7 d0             	movzwl %ax,%edx
80103d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d74:	01 d0                	add    %edx,%eax
80103d76:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d79:	e9 f4 00 00 00       	jmp    80103e72 <mpinit+0x152>
    switch(*p){
80103d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d81:	0f b6 00             	movzbl (%eax),%eax
80103d84:	0f b6 c0             	movzbl %al,%eax
80103d87:	83 f8 04             	cmp    $0x4,%eax
80103d8a:	0f 87 bf 00 00 00    	ja     80103e4f <mpinit+0x12f>
80103d90:	8b 04 85 00 8c 10 80 	mov    -0x7fef7400(,%eax,4),%eax
80103d97:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103da2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103da6:	0f b6 d0             	movzbl %al,%edx
80103da9:	a1 20 33 11 80       	mov    0x80113320,%eax
80103dae:	39 c2                	cmp    %eax,%edx
80103db0:	74 2d                	je     80103ddf <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103db2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103db5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103db9:	0f b6 d0             	movzbl %al,%edx
80103dbc:	a1 20 33 11 80       	mov    0x80113320,%eax
80103dc1:	89 54 24 08          	mov    %edx,0x8(%esp)
80103dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dc9:	c7 04 24 c2 8b 10 80 	movl   $0x80108bc2,(%esp)
80103dd0:	e8 2e c6 ff ff       	call   80100403 <cprintf>
        ismp = 0;
80103dd5:	c7 05 24 2d 11 80 00 	movl   $0x0,0x80112d24
80103ddc:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ddf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103de2:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103de6:	0f b6 c0             	movzbl %al,%eax
80103de9:	83 e0 02             	and    $0x2,%eax
80103dec:	85 c0                	test   %eax,%eax
80103dee:	74 15                	je     80103e05 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103df0:	a1 20 33 11 80       	mov    0x80113320,%eax
80103df5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dfb:	05 40 2d 11 80       	add    $0x80112d40,%eax
80103e00:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103e05:	8b 15 20 33 11 80    	mov    0x80113320,%edx
80103e0b:	a1 20 33 11 80       	mov    0x80113320,%eax
80103e10:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103e16:	81 c2 40 2d 11 80    	add    $0x80112d40,%edx
80103e1c:	88 02                	mov    %al,(%edx)
      ncpu++;
80103e1e:	a1 20 33 11 80       	mov    0x80113320,%eax
80103e23:	83 c0 01             	add    $0x1,%eax
80103e26:	a3 20 33 11 80       	mov    %eax,0x80113320
      p += sizeof(struct mpproc);
80103e2b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e2f:	eb 41                	jmp    80103e72 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e3a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e3e:	a2 20 2d 11 80       	mov    %al,0x80112d20
      p += sizeof(struct mpioapic);
80103e43:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e47:	eb 29                	jmp    80103e72 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e49:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e4d:	eb 23                	jmp    80103e72 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e52:	0f b6 00             	movzbl (%eax),%eax
80103e55:	0f b6 c0             	movzbl %al,%eax
80103e58:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e5c:	c7 04 24 e0 8b 10 80 	movl   $0x80108be0,(%esp)
80103e63:	e8 9b c5 ff ff       	call   80100403 <cprintf>
      ismp = 0;
80103e68:	c7 05 24 2d 11 80 00 	movl   $0x0,0x80112d24
80103e6f:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e75:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e78:	0f 82 00 ff ff ff    	jb     80103d7e <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103e7e:	a1 24 2d 11 80       	mov    0x80112d24,%eax
80103e83:	85 c0                	test   %eax,%eax
80103e85:	75 1d                	jne    80103ea4 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e87:	c7 05 20 33 11 80 01 	movl   $0x1,0x80113320
80103e8e:	00 00 00 
    lapic = 0;
80103e91:	c7 05 3c 2c 11 80 00 	movl   $0x0,0x80112c3c
80103e98:	00 00 00 
    ioapicid = 0;
80103e9b:	c6 05 20 2d 11 80 00 	movb   $0x0,0x80112d20
    return;
80103ea2:	eb 41                	jmp    80103ee5 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103ea4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ea7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103eab:	84 c0                	test   %al,%al
80103ead:	74 36                	je     80103ee5 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103eaf:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103eb6:	00 
80103eb7:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103ebe:	e8 0d fc ff ff       	call   80103ad0 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ec3:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103eca:	e8 e4 fb ff ff       	call   80103ab3 <inb>
80103ecf:	83 c8 01             	or     $0x1,%eax
80103ed2:	0f b6 c0             	movzbl %al,%eax
80103ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ed9:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103ee0:	e8 eb fb ff ff       	call   80103ad0 <outb>
  }
}
80103ee5:	c9                   	leave  
80103ee6:	c3                   	ret    

80103ee7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ee7:	55                   	push   %ebp
80103ee8:	89 e5                	mov    %esp,%ebp
80103eea:	83 ec 08             	sub    $0x8,%esp
80103eed:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ef7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103efa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103efe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f02:	ee                   	out    %al,(%dx)
}
80103f03:	c9                   	leave  
80103f04:	c3                   	ret    

80103f05 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f05:	55                   	push   %ebp
80103f06:	89 e5                	mov    %esp,%ebp
80103f08:	83 ec 0c             	sub    $0xc,%esp
80103f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f12:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f16:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f1c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f20:	0f b6 c0             	movzbl %al,%eax
80103f23:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f27:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f2e:	e8 b4 ff ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103f33:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f37:	66 c1 e8 08          	shr    $0x8,%ax
80103f3b:	0f b6 c0             	movzbl %al,%eax
80103f3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f42:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f49:	e8 99 ff ff ff       	call   80103ee7 <outb>
}
80103f4e:	c9                   	leave  
80103f4f:	c3                   	ret    

80103f50 <picenable>:

void
picenable(int irq)
{
80103f50:	55                   	push   %ebp
80103f51:	89 e5                	mov    %esp,%ebp
80103f53:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103f56:	8b 45 08             	mov    0x8(%ebp),%eax
80103f59:	ba 01 00 00 00       	mov    $0x1,%edx
80103f5e:	89 c1                	mov    %eax,%ecx
80103f60:	d3 e2                	shl    %cl,%edx
80103f62:	89 d0                	mov    %edx,%eax
80103f64:	f7 d0                	not    %eax
80103f66:	89 c2                	mov    %eax,%edx
80103f68:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f6f:	21 d0                	and    %edx,%eax
80103f71:	0f b7 c0             	movzwl %ax,%eax
80103f74:	89 04 24             	mov    %eax,(%esp)
80103f77:	e8 89 ff ff ff       	call   80103f05 <picsetmask>
}
80103f7c:	c9                   	leave  
80103f7d:	c3                   	ret    

80103f7e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f7e:	55                   	push   %ebp
80103f7f:	89 e5                	mov    %esp,%ebp
80103f81:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f84:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103f8b:	00 
80103f8c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f93:	e8 4f ff ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2+1, 0xFF);
80103f98:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103f9f:	00 
80103fa0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103fa7:	e8 3b ff ff ff       	call   80103ee7 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103fac:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103fb3:	00 
80103fb4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103fbb:	e8 27 ff ff ff       	call   80103ee7 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fc0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103fc7:	00 
80103fc8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103fcf:	e8 13 ff ff ff       	call   80103ee7 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fd4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103fdb:	00 
80103fdc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103fe3:	e8 ff fe ff ff       	call   80103ee7 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fe8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103fef:	00 
80103ff0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ff7:	e8 eb fe ff ff       	call   80103ee7 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ffc:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80104003:	00 
80104004:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010400b:	e8 d7 fe ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104010:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80104017:	00 
80104018:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010401f:	e8 c3 fe ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104024:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010402b:	00 
8010402c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104033:	e8 af fe ff ff       	call   80103ee7 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104038:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010403f:	00 
80104040:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104047:	e8 9b fe ff ff       	call   80103ee7 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010404c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80104053:	00 
80104054:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010405b:	e8 87 fe ff ff       	call   80103ee7 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104060:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80104067:	00 
80104068:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010406f:	e8 73 fe ff ff       	call   80103ee7 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80104074:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
8010407b:	00 
8010407c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104083:	e8 5f fe ff ff       	call   80103ee7 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80104088:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010408f:	00 
80104090:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80104097:	e8 4b fe ff ff       	call   80103ee7 <outb>

  if(irqmask != 0xFFFF)
8010409c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
801040a3:	66 83 f8 ff          	cmp    $0xffff,%ax
801040a7:	74 12                	je     801040bb <picinit+0x13d>
    picsetmask(irqmask);
801040a9:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
801040b0:	0f b7 c0             	movzwl %ax,%eax
801040b3:	89 04 24             	mov    %eax,(%esp)
801040b6:	e8 4a fe ff ff       	call   80103f05 <picsetmask>
}
801040bb:	c9                   	leave  
801040bc:	c3                   	ret    

801040bd <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040bd:	55                   	push   %ebp
801040be:	89 e5                	mov    %esp,%ebp
801040c0:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
801040c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801040ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801040d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d6:	8b 10                	mov    (%eax),%edx
801040d8:	8b 45 08             	mov    0x8(%ebp),%eax
801040db:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040dd:	e8 fc ce ff ff       	call   80100fde <filealloc>
801040e2:	8b 55 08             	mov    0x8(%ebp),%edx
801040e5:	89 02                	mov    %eax,(%edx)
801040e7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ea:	8b 00                	mov    (%eax),%eax
801040ec:	85 c0                	test   %eax,%eax
801040ee:	0f 84 c8 00 00 00    	je     801041bc <pipealloc+0xff>
801040f4:	e8 e5 ce ff ff       	call   80100fde <filealloc>
801040f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801040fc:	89 02                	mov    %eax,(%edx)
801040fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104101:	8b 00                	mov    (%eax),%eax
80104103:	85 c0                	test   %eax,%eax
80104105:	0f 84 b1 00 00 00    	je     801041bc <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010410b:	e8 25 eb ff ff       	call   80102c35 <kalloc>
80104110:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104113:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104117:	75 05                	jne    8010411e <pipealloc+0x61>
    goto bad;
80104119:	e9 9e 00 00 00       	jmp    801041bc <pipealloc+0xff>
  p->readopen = 1;
8010411e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104121:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104128:	00 00 00 
  p->writeopen = 1;
8010412b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104135:	00 00 00 
  p->nwrite = 0;
80104138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104142:	00 00 00 
  p->nread = 0;
80104145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104148:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010414f:	00 00 00 
  initlock(&p->lock, "pipe");
80104152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104155:	c7 44 24 04 14 8c 10 	movl   $0x80108c14,0x4(%esp)
8010415c:	80 
8010415d:	89 04 24             	mov    %eax,(%esp)
80104160:	e8 c5 0e 00 00       	call   8010502a <initlock>
  (*f0)->type = FD_PIPE;
80104165:	8b 45 08             	mov    0x8(%ebp),%eax
80104168:	8b 00                	mov    (%eax),%eax
8010416a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104170:	8b 45 08             	mov    0x8(%ebp),%eax
80104173:	8b 00                	mov    (%eax),%eax
80104175:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104179:	8b 45 08             	mov    0x8(%ebp),%eax
8010417c:	8b 00                	mov    (%eax),%eax
8010417e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104182:	8b 45 08             	mov    0x8(%ebp),%eax
80104185:	8b 00                	mov    (%eax),%eax
80104187:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010418a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010418d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104190:	8b 00                	mov    (%eax),%eax
80104192:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104198:	8b 45 0c             	mov    0xc(%ebp),%eax
8010419b:	8b 00                	mov    (%eax),%eax
8010419d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a4:	8b 00                	mov    (%eax),%eax
801041a6:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801041aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ad:	8b 00                	mov    (%eax),%eax
801041af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b2:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041b5:	b8 00 00 00 00       	mov    $0x0,%eax
801041ba:	eb 42                	jmp    801041fe <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
801041bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041c0:	74 0b                	je     801041cd <pipealloc+0x110>
    kfree((char*)p);
801041c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c5:	89 04 24             	mov    %eax,(%esp)
801041c8:	e8 cf e9 ff ff       	call   80102b9c <kfree>
  if(*f0)
801041cd:	8b 45 08             	mov    0x8(%ebp),%eax
801041d0:	8b 00                	mov    (%eax),%eax
801041d2:	85 c0                	test   %eax,%eax
801041d4:	74 0d                	je     801041e3 <pipealloc+0x126>
    fileclose(*f0);
801041d6:	8b 45 08             	mov    0x8(%ebp),%eax
801041d9:	8b 00                	mov    (%eax),%eax
801041db:	89 04 24             	mov    %eax,(%esp)
801041de:	e8 a3 ce ff ff       	call   80101086 <fileclose>
  if(*f1)
801041e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e6:	8b 00                	mov    (%eax),%eax
801041e8:	85 c0                	test   %eax,%eax
801041ea:	74 0d                	je     801041f9 <pipealloc+0x13c>
    fileclose(*f1);
801041ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ef:	8b 00                	mov    (%eax),%eax
801041f1:	89 04 24             	mov    %eax,(%esp)
801041f4:	e8 8d ce ff ff       	call   80101086 <fileclose>
  return -1;
801041f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041fe:	c9                   	leave  
801041ff:	c3                   	ret    

80104200 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104200:	55                   	push   %ebp
80104201:	89 e5                	mov    %esp,%ebp
80104203:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104206:	8b 45 08             	mov    0x8(%ebp),%eax
80104209:	89 04 24             	mov    %eax,(%esp)
8010420c:	e8 3a 0e 00 00       	call   8010504b <acquire>
  if(writable){
80104211:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104215:	74 1f                	je     80104236 <pipeclose+0x36>
    p->writeopen = 0;
80104217:	8b 45 08             	mov    0x8(%ebp),%eax
8010421a:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104221:	00 00 00 
    wakeup(&p->nread);
80104224:	8b 45 08             	mov    0x8(%ebp),%eax
80104227:	05 34 02 00 00       	add    $0x234,%eax
8010422c:	89 04 24             	mov    %eax,(%esp)
8010422f:	e8 1c 0c 00 00       	call   80104e50 <wakeup>
80104234:	eb 1d                	jmp    80104253 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104236:	8b 45 08             	mov    0x8(%ebp),%eax
80104239:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104240:	00 00 00 
    wakeup(&p->nwrite);
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	05 38 02 00 00       	add    $0x238,%eax
8010424b:	89 04 24             	mov    %eax,(%esp)
8010424e:	e8 fd 0b 00 00       	call   80104e50 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010425c:	85 c0                	test   %eax,%eax
8010425e:	75 25                	jne    80104285 <pipeclose+0x85>
80104260:	8b 45 08             	mov    0x8(%ebp),%eax
80104263:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104269:	85 c0                	test   %eax,%eax
8010426b:	75 18                	jne    80104285 <pipeclose+0x85>
    release(&p->lock);
8010426d:	8b 45 08             	mov    0x8(%ebp),%eax
80104270:	89 04 24             	mov    %eax,(%esp)
80104273:	e8 35 0e 00 00       	call   801050ad <release>
    kfree((char*)p);
80104278:	8b 45 08             	mov    0x8(%ebp),%eax
8010427b:	89 04 24             	mov    %eax,(%esp)
8010427e:	e8 19 e9 ff ff       	call   80102b9c <kfree>
80104283:	eb 0b                	jmp    80104290 <pipeclose+0x90>
  } else
    release(&p->lock);
80104285:	8b 45 08             	mov    0x8(%ebp),%eax
80104288:	89 04 24             	mov    %eax,(%esp)
8010428b:	e8 1d 0e 00 00       	call   801050ad <release>
}
80104290:	c9                   	leave  
80104291:	c3                   	ret    

80104292 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104292:	55                   	push   %ebp
80104293:	89 e5                	mov    %esp,%ebp
80104295:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104298:	8b 45 08             	mov    0x8(%ebp),%eax
8010429b:	89 04 24             	mov    %eax,(%esp)
8010429e:	e8 a8 0d 00 00       	call   8010504b <acquire>
  for(i = 0; i < n; i++){
801042a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042aa:	e9 a6 00 00 00       	jmp    80104355 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042af:	eb 57                	jmp    80104308 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
801042b1:	8b 45 08             	mov    0x8(%ebp),%eax
801042b4:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042ba:	85 c0                	test   %eax,%eax
801042bc:	74 0d                	je     801042cb <pipewrite+0x39>
801042be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042c4:	8b 40 24             	mov    0x24(%eax),%eax
801042c7:	85 c0                	test   %eax,%eax
801042c9:	74 15                	je     801042e0 <pipewrite+0x4e>
        release(&p->lock);
801042cb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ce:	89 04 24             	mov    %eax,(%esp)
801042d1:	e8 d7 0d 00 00       	call   801050ad <release>
        return -1;
801042d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042db:	e9 9f 00 00 00       	jmp    8010437f <pipewrite+0xed>
      }
      wakeup(&p->nread);
801042e0:	8b 45 08             	mov    0x8(%ebp),%eax
801042e3:	05 34 02 00 00       	add    $0x234,%eax
801042e8:	89 04 24             	mov    %eax,(%esp)
801042eb:	e8 60 0b 00 00       	call   80104e50 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 55 08             	mov    0x8(%ebp),%edx
801042f6:	81 c2 38 02 00 00    	add    $0x238,%edx
801042fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104300:	89 14 24             	mov    %edx,(%esp)
80104303:	e8 6f 0a 00 00       	call   80104d77 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104308:	8b 45 08             	mov    0x8(%ebp),%eax
8010430b:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104311:	8b 45 08             	mov    0x8(%ebp),%eax
80104314:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010431a:	05 00 02 00 00       	add    $0x200,%eax
8010431f:	39 c2                	cmp    %eax,%edx
80104321:	74 8e                	je     801042b1 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010432c:	8d 48 01             	lea    0x1(%eax),%ecx
8010432f:	8b 55 08             	mov    0x8(%ebp),%edx
80104332:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104338:	25 ff 01 00 00       	and    $0x1ff,%eax
8010433d:	89 c1                	mov    %eax,%ecx
8010433f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104342:	8b 45 0c             	mov    0xc(%ebp),%eax
80104345:	01 d0                	add    %edx,%eax
80104347:	0f b6 10             	movzbl (%eax),%edx
8010434a:	8b 45 08             	mov    0x8(%ebp),%eax
8010434d:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104351:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104358:	3b 45 10             	cmp    0x10(%ebp),%eax
8010435b:	0f 8c 4e ff ff ff    	jl     801042af <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	05 34 02 00 00       	add    $0x234,%eax
80104369:	89 04 24             	mov    %eax,(%esp)
8010436c:	e8 df 0a 00 00       	call   80104e50 <wakeup>
  release(&p->lock);
80104371:	8b 45 08             	mov    0x8(%ebp),%eax
80104374:	89 04 24             	mov    %eax,(%esp)
80104377:	e8 31 0d 00 00       	call   801050ad <release>
  return n;
8010437c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010437f:	c9                   	leave  
80104380:	c3                   	ret    

80104381 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104381:	55                   	push   %ebp
80104382:	89 e5                	mov    %esp,%ebp
80104384:	53                   	push   %ebx
80104385:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104388:	8b 45 08             	mov    0x8(%ebp),%eax
8010438b:	89 04 24             	mov    %eax,(%esp)
8010438e:	e8 b8 0c 00 00       	call   8010504b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104393:	eb 3a                	jmp    801043cf <piperead+0x4e>
    if(proc->killed){
80104395:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010439b:	8b 40 24             	mov    0x24(%eax),%eax
8010439e:	85 c0                	test   %eax,%eax
801043a0:	74 15                	je     801043b7 <piperead+0x36>
      release(&p->lock);
801043a2:	8b 45 08             	mov    0x8(%ebp),%eax
801043a5:	89 04 24             	mov    %eax,(%esp)
801043a8:	e8 00 0d 00 00       	call   801050ad <release>
      return -1;
801043ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b2:	e9 b5 00 00 00       	jmp    8010446c <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043b7:	8b 45 08             	mov    0x8(%ebp),%eax
801043ba:	8b 55 08             	mov    0x8(%ebp),%edx
801043bd:	81 c2 34 02 00 00    	add    $0x234,%edx
801043c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801043c7:	89 14 24             	mov    %edx,(%esp)
801043ca:	e8 a8 09 00 00       	call   80104d77 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043cf:	8b 45 08             	mov    0x8(%ebp),%eax
801043d2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043d8:	8b 45 08             	mov    0x8(%ebp),%eax
801043db:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043e1:	39 c2                	cmp    %eax,%edx
801043e3:	75 0d                	jne    801043f2 <piperead+0x71>
801043e5:	8b 45 08             	mov    0x8(%ebp),%eax
801043e8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043ee:	85 c0                	test   %eax,%eax
801043f0:	75 a3                	jne    80104395 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043f9:	eb 4b                	jmp    80104446 <piperead+0xc5>
    if(p->nread == p->nwrite)
801043fb:	8b 45 08             	mov    0x8(%ebp),%eax
801043fe:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104404:	8b 45 08             	mov    0x8(%ebp),%eax
80104407:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010440d:	39 c2                	cmp    %eax,%edx
8010440f:	75 02                	jne    80104413 <piperead+0x92>
      break;
80104411:	eb 3b                	jmp    8010444e <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104413:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104416:	8b 45 0c             	mov    0xc(%ebp),%eax
80104419:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010441c:	8b 45 08             	mov    0x8(%ebp),%eax
8010441f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104425:	8d 48 01             	lea    0x1(%eax),%ecx
80104428:	8b 55 08             	mov    0x8(%ebp),%edx
8010442b:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104431:	25 ff 01 00 00       	and    $0x1ff,%eax
80104436:	89 c2                	mov    %eax,%edx
80104438:	8b 45 08             	mov    0x8(%ebp),%eax
8010443b:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104440:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104442:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	3b 45 10             	cmp    0x10(%ebp),%eax
8010444c:	7c ad                	jl     801043fb <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010444e:	8b 45 08             	mov    0x8(%ebp),%eax
80104451:	05 38 02 00 00       	add    $0x238,%eax
80104456:	89 04 24             	mov    %eax,(%esp)
80104459:	e8 f2 09 00 00       	call   80104e50 <wakeup>
  release(&p->lock);
8010445e:	8b 45 08             	mov    0x8(%ebp),%eax
80104461:	89 04 24             	mov    %eax,(%esp)
80104464:	e8 44 0c 00 00       	call   801050ad <release>
  return i;
80104469:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010446c:	83 c4 24             	add    $0x24,%esp
8010446f:	5b                   	pop    %ebx
80104470:	5d                   	pop    %ebp
80104471:	c3                   	ret    

80104472 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104472:	55                   	push   %ebp
80104473:	89 e5                	mov    %esp,%ebp
80104475:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104478:	9c                   	pushf  
80104479:	58                   	pop    %eax
8010447a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010447d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104480:	c9                   	leave  
80104481:	c3                   	ret    

80104482 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104482:	55                   	push   %ebp
80104483:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104485:	fb                   	sti    
}
80104486:	5d                   	pop    %ebp
80104487:	c3                   	ret    

80104488 <hlt>:

static inline void
hlt(void)
{
80104488:	55                   	push   %ebp
80104489:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
8010448b:	f4                   	hlt    
}
8010448c:	5d                   	pop    %ebp
8010448d:	c3                   	ret    

8010448e <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010448e:	55                   	push   %ebp
8010448f:	89 e5                	mov    %esp,%ebp
80104491:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104494:	c7 44 24 04 19 8c 10 	movl   $0x80108c19,0x4(%esp)
8010449b:	80 
8010449c:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801044a3:	e8 82 0b 00 00       	call   8010502a <initlock>
  // Seed RNG with current time
  sgenrand(unixtime());
801044a8:	e8 a8 ee ff ff       	call   80103355 <unixtime>
801044ad:	89 04 24             	mov    %eax,(%esp)
801044b0:	e8 46 33 00 00       	call   801077fb <sgenrand>
}
801044b5:	c9                   	leave  
801044b6:	c3                   	ret    

801044b7 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044b7:	55                   	push   %ebp
801044b8:	89 e5                	mov    %esp,%ebp
801044ba:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044bd:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801044c4:	e8 82 0b 00 00       	call   8010504b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044c9:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
801044d0:	eb 5a                	jmp    8010452c <allocproc+0x75>
    if(p->state == UNUSED)
801044d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d5:	8b 40 0c             	mov    0xc(%eax),%eax
801044d8:	85 c0                	test   %eax,%eax
801044da:	75 4c                	jne    80104528 <allocproc+0x71>
      goto found;
801044dc:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044e7:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044ec:	8d 50 01             	lea    0x1(%eax),%edx
801044ef:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801044f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f8:	89 42 10             	mov    %eax,0x10(%edx)
	p->tickets = 20;        // Allocate 20 tickets
801044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fe:	c7 40 7c 14 00 00 00 	movl   $0x14,0x7c(%eax)
  release(&ptable.lock);
80104505:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010450c:	e8 9c 0b 00 00       	call   801050ad <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104511:	e8 1f e7 ff ff       	call   80102c35 <kalloc>
80104516:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104519:	89 42 08             	mov    %eax,0x8(%edx)
8010451c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451f:	8b 40 08             	mov    0x8(%eax),%eax
80104522:	85 c0                	test   %eax,%eax
80104524:	75 33                	jne    80104559 <allocproc+0xa2>
80104526:	eb 20                	jmp    80104548 <allocproc+0x91>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104528:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010452c:	81 7d f4 74 53 11 80 	cmpl   $0x80115374,-0xc(%ebp)
80104533:	72 9d                	jb     801044d2 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104535:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010453c:	e8 6c 0b 00 00       	call   801050ad <release>
  return 0;
80104541:	b8 00 00 00 00       	mov    $0x0,%eax
80104546:	eb 76                	jmp    801045be <allocproc+0x107>
	p->tickets = 20;        // Allocate 20 tickets
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104552:	b8 00 00 00 00       	mov    $0x0,%eax
80104557:	eb 65                	jmp    801045be <allocproc+0x107>
  }
  sp = p->kstack + KSTACKSIZE;
80104559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455c:	8b 40 08             	mov    0x8(%eax),%eax
8010455f:	05 00 10 00 00       	add    $0x1000,%eax
80104564:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104567:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010456b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104571:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104574:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104578:	ba 30 67 10 80       	mov    $0x80106730,%edx
8010457d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104580:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104582:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104589:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010458c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010458f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104592:	8b 40 1c             	mov    0x1c(%eax),%eax
80104595:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010459c:	00 
8010459d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801045a4:	00 
801045a5:	89 04 24             	mov    %eax,(%esp)
801045a8:	e8 f2 0c 00 00       	call   8010529f <memset>
  p->context->eip = (uint)forkret;
801045ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b0:	8b 40 1c             	mov    0x1c(%eax),%eax
801045b3:	ba 38 4d 10 80       	mov    $0x80104d38,%edx
801045b8:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045be:	c9                   	leave  
801045bf:	c3                   	ret    

801045c0 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045c0:	55                   	push   %ebp
801045c1:	89 e5                	mov    %esp,%ebp
801045c3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045c6:	e8 ec fe ff ff       	call   801044b7 <allocproc>
801045cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d1:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
801045d6:	e8 89 3a 00 00       	call   80108064 <setupkvm>
801045db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045de:	89 42 04             	mov    %eax,0x4(%edx)
801045e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e4:	8b 40 04             	mov    0x4(%eax),%eax
801045e7:	85 c0                	test   %eax,%eax
801045e9:	75 0c                	jne    801045f7 <userinit+0x37>
    panic("userinit: out of memory?");
801045eb:	c7 04 24 20 8c 10 80 	movl   $0x80108c20,(%esp)
801045f2:	e8 e0 bf ff ff       	call   801005d7 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045f7:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ff:	8b 40 04             	mov    0x4(%eax),%eax
80104602:	89 54 24 08          	mov    %edx,0x8(%esp)
80104606:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
8010460d:	80 
8010460e:	89 04 24             	mov    %eax,(%esp)
80104611:	e8 a6 3c 00 00       	call   801082bc <inituvm>
  p->sz = PGSIZE;
80104616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104619:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010461f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104622:	8b 40 18             	mov    0x18(%eax),%eax
80104625:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010462c:	00 
8010462d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104634:	00 
80104635:	89 04 24             	mov    %eax,(%esp)
80104638:	e8 62 0c 00 00       	call   8010529f <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	8b 40 18             	mov    0x18(%eax),%eax
80104643:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464c:	8b 40 18             	mov    0x18(%eax),%eax
8010464f:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104658:	8b 40 18             	mov    0x18(%eax),%eax
8010465b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010465e:	8b 52 18             	mov    0x18(%edx),%edx
80104661:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104665:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466c:	8b 40 18             	mov    0x18(%eax),%eax
8010466f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104672:	8b 52 18             	mov    0x18(%edx),%edx
80104675:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104679:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010467d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104680:	8b 40 18             	mov    0x18(%eax),%eax
80104683:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010468a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468d:	8b 40 18             	mov    0x18(%eax),%eax
80104690:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469a:	8b 40 18             	mov    0x18(%eax),%eax
8010469d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a7:	83 c0 6c             	add    $0x6c,%eax
801046aa:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801046b1:	00 
801046b2:	c7 44 24 04 39 8c 10 	movl   $0x80108c39,0x4(%esp)
801046b9:	80 
801046ba:	89 04 24             	mov    %eax,(%esp)
801046bd:	e8 fd 0d 00 00       	call   801054bf <safestrcpy>
  p->cwd = namei("/");
801046c2:	c7 04 24 42 8c 10 80 	movl   $0x80108c42,(%esp)
801046c9:	e8 54 de ff ff       	call   80102522 <namei>
801046ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046d1:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046de:	c9                   	leave  
801046df:	c3                   	ret    

801046e0 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046e0:	55                   	push   %ebp
801046e1:	89 e5                	mov    %esp,%ebp
801046e3:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801046e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ec:	8b 00                	mov    (%eax),%eax
801046ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046f1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046f5:	7e 34                	jle    8010472b <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046f7:	8b 55 08             	mov    0x8(%ebp),%edx
801046fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fd:	01 c2                	add    %eax,%edx
801046ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104705:	8b 40 04             	mov    0x4(%eax),%eax
80104708:	89 54 24 08          	mov    %edx,0x8(%esp)
8010470c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010470f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104713:	89 04 24             	mov    %eax,(%esp)
80104716:	e8 17 3d 00 00       	call   80108432 <allocuvm>
8010471b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010471e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104722:	75 41                	jne    80104765 <growproc+0x85>
      return -1;
80104724:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104729:	eb 58                	jmp    80104783 <growproc+0xa3>
  } else if(n < 0){
8010472b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010472f:	79 34                	jns    80104765 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104731:	8b 55 08             	mov    0x8(%ebp),%edx
80104734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104737:	01 c2                	add    %eax,%edx
80104739:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473f:	8b 40 04             	mov    0x4(%eax),%eax
80104742:	89 54 24 08          	mov    %edx,0x8(%esp)
80104746:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104749:	89 54 24 04          	mov    %edx,0x4(%esp)
8010474d:	89 04 24             	mov    %eax,(%esp)
80104750:	e8 b7 3d 00 00       	call   8010850c <deallocuvm>
80104755:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104758:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010475c:	75 07                	jne    80104765 <growproc+0x85>
      return -1;
8010475e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104763:	eb 1e                	jmp    80104783 <growproc+0xa3>
  }
  proc->sz = sz;
80104765:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010476e:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104770:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104776:	89 04 24             	mov    %eax,(%esp)
80104779:	e8 d7 39 00 00       	call   80108155 <switchuvm>
  return 0;
8010477e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104783:	c9                   	leave  
80104784:	c3                   	ret    

80104785 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104785:	55                   	push   %ebp
80104786:	89 e5                	mov    %esp,%ebp
80104788:	57                   	push   %edi
80104789:	56                   	push   %esi
8010478a:	53                   	push   %ebx
8010478b:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010478e:	e8 24 fd ff ff       	call   801044b7 <allocproc>
80104793:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010479a:	75 0a                	jne    801047a6 <fork+0x21>
    return -1;
8010479c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a1:	e9 52 01 00 00       	jmp    801048f8 <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801047a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ac:	8b 10                	mov    (%eax),%edx
801047ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b4:	8b 40 04             	mov    0x4(%eax),%eax
801047b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801047bb:	89 04 24             	mov    %eax,(%esp)
801047be:	e8 e5 3e 00 00       	call   801086a8 <copyuvm>
801047c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047c6:	89 42 04             	mov    %eax,0x4(%edx)
801047c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cc:	8b 40 04             	mov    0x4(%eax),%eax
801047cf:	85 c0                	test   %eax,%eax
801047d1:	75 2c                	jne    801047ff <fork+0x7a>
    kfree(np->kstack);
801047d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d6:	8b 40 08             	mov    0x8(%eax),%eax
801047d9:	89 04 24             	mov    %eax,(%esp)
801047dc:	e8 bb e3 ff ff       	call   80102b9c <kfree>
    np->kstack = 0;
801047e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ee:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047fa:	e9 f9 00 00 00       	jmp    801048f8 <fork+0x173>
  }
  np->sz = proc->sz;
801047ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104805:	8b 10                	mov    (%eax),%edx
80104807:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480a:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010480c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104813:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104816:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104819:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481c:	8b 50 18             	mov    0x18(%eax),%edx
8010481f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104825:	8b 40 18             	mov    0x18(%eax),%eax
80104828:	89 c3                	mov    %eax,%ebx
8010482a:	b8 13 00 00 00       	mov    $0x13,%eax
8010482f:	89 d7                	mov    %edx,%edi
80104831:	89 de                	mov    %ebx,%esi
80104833:	89 c1                	mov    %eax,%ecx
80104835:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104837:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010483a:	8b 40 18             	mov    0x18(%eax),%eax
8010483d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104844:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010484b:	eb 3d                	jmp    8010488a <fork+0x105>
    if(proc->ofile[i])
8010484d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104853:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104856:	83 c2 08             	add    $0x8,%edx
80104859:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010485d:	85 c0                	test   %eax,%eax
8010485f:	74 25                	je     80104886 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104861:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104867:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010486a:	83 c2 08             	add    $0x8,%edx
8010486d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104871:	89 04 24             	mov    %eax,(%esp)
80104874:	e8 c5 c7 ff ff       	call   8010103e <filedup>
80104879:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010487c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010487f:	83 c1 08             	add    $0x8,%ecx
80104882:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104886:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010488a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010488e:	7e bd                	jle    8010484d <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104890:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104896:	8b 40 68             	mov    0x68(%eax),%eax
80104899:	89 04 24             	mov    %eax,(%esp)
8010489c:	e8 9e d0 ff ff       	call   8010193f <idup>
801048a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048a4:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ad:	8d 50 6c             	lea    0x6c(%eax),%edx
801048b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b3:	83 c0 6c             	add    $0x6c,%eax
801048b6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801048bd:	00 
801048be:	89 54 24 04          	mov    %edx,0x4(%esp)
801048c2:	89 04 24             	mov    %eax,(%esp)
801048c5:	e8 f5 0b 00 00       	call   801054bf <safestrcpy>
 
  pid = np->pid;
801048ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048cd:	8b 40 10             	mov    0x10(%eax),%eax
801048d0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048d3:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801048da:	e8 6c 07 00 00       	call   8010504b <acquire>
  np->state = RUNNABLE;
801048df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048e9:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801048f0:	e8 b8 07 00 00       	call   801050ad <release>
  
  return pid;
801048f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048f8:	83 c4 2c             	add    $0x2c,%esp
801048fb:	5b                   	pop    %ebx
801048fc:	5e                   	pop    %esi
801048fd:	5f                   	pop    %edi
801048fe:	5d                   	pop    %ebp
801048ff:	c3                   	ret    

80104900 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104900:	55                   	push   %ebp
80104901:	89 e5                	mov    %esp,%ebp
80104903:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104906:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010490d:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104912:	39 c2                	cmp    %eax,%edx
80104914:	75 0c                	jne    80104922 <exit+0x22>
    panic("init exiting");
80104916:	c7 04 24 44 8c 10 80 	movl   $0x80108c44,(%esp)
8010491d:	e8 b5 bc ff ff       	call   801005d7 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104922:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104929:	eb 44                	jmp    8010496f <exit+0x6f>
    if(proc->ofile[fd]){
8010492b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104931:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104934:	83 c2 08             	add    $0x8,%edx
80104937:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010493b:	85 c0                	test   %eax,%eax
8010493d:	74 2c                	je     8010496b <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010493f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104945:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104948:	83 c2 08             	add    $0x8,%edx
8010494b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010494f:	89 04 24             	mov    %eax,(%esp)
80104952:	e8 2f c7 ff ff       	call   80101086 <fileclose>
      proc->ofile[fd] = 0;
80104957:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010495d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104960:	83 c2 08             	add    $0x8,%edx
80104963:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010496a:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010496b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010496f:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104973:	7e b6                	jle    8010492b <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104975:	e8 37 ec ff ff       	call   801035b1 <begin_op>
  iput(proc->cwd);
8010497a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104980:	8b 40 68             	mov    0x68(%eax),%eax
80104983:	89 04 24             	mov    %eax,(%esp)
80104986:	e8 9f d1 ff ff       	call   80101b2a <iput>
  end_op();
8010498b:	e8 a5 ec ff ff       	call   80103635 <end_op>
  proc->cwd = 0;
80104990:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104996:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010499d:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801049a4:	e8 a2 06 00 00       	call   8010504b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049af:	8b 40 14             	mov    0x14(%eax),%eax
801049b2:	89 04 24             	mov    %eax,(%esp)
801049b5:	e8 58 04 00 00       	call   80104e12 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049ba:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
801049c1:	eb 38                	jmp    801049fb <exit+0xfb>
    if(p->parent == proc){
801049c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c6:	8b 50 14             	mov    0x14(%eax),%edx
801049c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049cf:	39 c2                	cmp    %eax,%edx
801049d1:	75 24                	jne    801049f7 <exit+0xf7>
      p->parent = initproc;
801049d3:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
801049d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049dc:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e2:	8b 40 0c             	mov    0xc(%eax),%eax
801049e5:	83 f8 05             	cmp    $0x5,%eax
801049e8:	75 0d                	jne    801049f7 <exit+0xf7>
        wakeup1(initproc);
801049ea:	a1 68 b6 10 80       	mov    0x8010b668,%eax
801049ef:	89 04 24             	mov    %eax,(%esp)
801049f2:	e8 1b 04 00 00       	call   80104e12 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f7:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801049fb:	81 7d f4 74 53 11 80 	cmpl   $0x80115374,-0xc(%ebp)
80104a02:	72 bf                	jb     801049c3 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a0a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a11:	e8 3e 02 00 00       	call   80104c54 <sched>
  panic("zombie exit");
80104a16:	c7 04 24 51 8c 10 80 	movl   $0x80108c51,(%esp)
80104a1d:	e8 b5 bb ff ff       	call   801005d7 <panic>

80104a22 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a22:	55                   	push   %ebp
80104a23:	89 e5                	mov    %esp,%ebp
80104a25:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a28:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104a2f:	e8 17 06 00 00       	call   8010504b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a3b:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
80104a42:	e9 9a 00 00 00       	jmp    80104ae1 <wait+0xbf>
      if(p->parent != proc)
80104a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4a:	8b 50 14             	mov    0x14(%eax),%edx
80104a4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a53:	39 c2                	cmp    %eax,%edx
80104a55:	74 05                	je     80104a5c <wait+0x3a>
        continue;
80104a57:	e9 81 00 00 00       	jmp    80104add <wait+0xbb>
      havekids = 1;
80104a5c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a66:	8b 40 0c             	mov    0xc(%eax),%eax
80104a69:	83 f8 05             	cmp    $0x5,%eax
80104a6c:	75 6f                	jne    80104add <wait+0xbb>
        // Found one.
        pid = p->pid;
80104a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a71:	8b 40 10             	mov    0x10(%eax),%eax
80104a74:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7a:	8b 40 08             	mov    0x8(%eax),%eax
80104a7d:	89 04 24             	mov    %eax,(%esp)
80104a80:	e8 17 e1 ff ff       	call   80102b9c <kfree>
        p->kstack = 0;
80104a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a88:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a92:	8b 40 04             	mov    0x4(%eax),%eax
80104a95:	89 04 24             	mov    %eax,(%esp)
80104a98:	e8 2b 3b 00 00       	call   801085c8 <freevm>
        p->state = UNUSED;
80104a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aaa:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abe:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac5:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104acc:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104ad3:	e8 d5 05 00 00       	call   801050ad <release>
        return pid;
80104ad8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104adb:	eb 52                	jmp    80104b2f <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104add:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104ae1:	81 7d f4 74 53 11 80 	cmpl   $0x80115374,-0xc(%ebp)
80104ae8:	0f 82 59 ff ff ff    	jb     80104a47 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104aee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104af2:	74 0d                	je     80104b01 <wait+0xdf>
80104af4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104afa:	8b 40 24             	mov    0x24(%eax),%eax
80104afd:	85 c0                	test   %eax,%eax
80104aff:	74 13                	je     80104b14 <wait+0xf2>
      release(&ptable.lock);
80104b01:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104b08:	e8 a0 05 00 00       	call   801050ad <release>
      return -1;
80104b0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b12:	eb 1b                	jmp    80104b2f <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1a:	c7 44 24 04 40 33 11 	movl   $0x80113340,0x4(%esp)
80104b21:	80 
80104b22:	89 04 24             	mov    %eax,(%esp)
80104b25:	e8 4d 02 00 00       	call   80104d77 <sleep>
  }
80104b2a:	e9 05 ff ff ff       	jmp    80104a34 <wait+0x12>
}
80104b2f:	c9                   	leave  
80104b30:	c3                   	ret    

80104b31 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b31:	55                   	push   %ebp
80104b32:	89 e5                	mov    %esp,%ebp
80104b34:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  int foundproc = 1;
80104b37:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  int current_count;
  int total_tickets;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b3e:	e8 3f f9 ff ff       	call   80104482 <sti>

    if (!foundproc) hlt();
80104b43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b47:	75 05                	jne    80104b4e <scheduler+0x1d>
80104b49:	e8 3a f9 ff ff       	call   80104488 <hlt>
    foundproc = 0;
80104b4e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

		// Set ticket counter value to 0
    current_count = 0;
80104b55:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    // Obtain total tickets by adding tickets held by RUNNABLE processes
		total_tickets = 0;
80104b5c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b63:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
80104b6a:	eb 18                	jmp    80104b84 <scheduler+0x53>
		  if(p->state == RUNNABLE)
80104b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b72:	83 f8 03             	cmp    $0x3,%eax
80104b75:	75 09                	jne    80104b80 <scheduler+0x4f>
		    total_tickets += p->tickets;
80104b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7a:	8b 40 7c             	mov    0x7c(%eax),%eax
80104b7d:	01 45 e8             	add    %eax,-0x18(%ebp)
		// Set ticket counter value to 0
    current_count = 0;

    // Obtain total tickets by adding tickets held by RUNNABLE processes
		total_tickets = 0;
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b80:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104b84:	81 7d f4 74 53 11 80 	cmpl   $0x80115374,-0xc(%ebp)
80104b8b:	72 df                	jb     80104b6c <scheduler+0x3b>
		  if(p->state == RUNNABLE)
		    total_tickets += p->tickets;

    // Pick a random ticket number
    winning_ticket = random_at_most((long) total_tickets);
80104b8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b90:	89 04 24             	mov    %eax,(%esp)
80104b93:	e8 4d 2e 00 00       	call   801079e5 <random_at_most>
80104b98:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b9b:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104ba2:	e8 a4 04 00 00       	call   8010504b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ba7:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
80104bae:	e9 83 00 00 00       	jmp    80104c36 <scheduler+0x105>
      if(p->state != RUNNABLE)
80104bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb6:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb9:	83 f8 03             	cmp    $0x3,%eax
80104bbc:	74 02                	je     80104bc0 <scheduler+0x8f>
        continue;
80104bbe:	eb 72                	jmp    80104c32 <scheduler+0x101>

			// For each RUNNABLE process, add its ticket count to current_count.
      // If the winning ticket number falls between the previous current_count
      // and the new one, we pick the process as it's holding the winning
      // ticket. Until then, we keep looping through RUNNABLE processes.
      current_count += p->tickets;
80104bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc3:	8b 40 7c             	mov    0x7c(%eax),%eax
80104bc6:	01 45 ec             	add    %eax,-0x14(%ebp)
      if (current_count < winning_ticket)
80104bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bcc:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80104bcf:	7d 0b                	jge    80104bdc <scheduler+0xab>
      {
        current_count += p->tickets;
80104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd4:	8b 40 7c             	mov    0x7c(%eax),%eax
80104bd7:	01 45 ec             	add    %eax,-0x14(%ebp)
        continue;
80104bda:	eb 56                	jmp    80104c32 <scheduler+0x101>
      }

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      foundproc = 1;
80104bdc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      proc = p;
80104be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be6:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bef:	89 04 24             	mov    %eax,(%esp)
80104bf2:	e8 5e 35 00 00       	call   80108155 <switchuvm>
      p->state = RUNNING;
80104bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfa:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104c01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c07:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c0a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c11:	83 c2 04             	add    $0x4,%edx
80104c14:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c18:	89 14 24             	mov    %edx,(%esp)
80104c1b:	e8 10 09 00 00       	call   80105530 <swtch>
      switchkvm();
80104c20:	e8 13 35 00 00       	call   80108138 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c25:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c2c:	00 00 00 00 

			// Process is done running
      break;
80104c30:	eb 11                	jmp    80104c43 <scheduler+0x112>
    // Pick a random ticket number
    winning_ticket = random_at_most((long) total_tickets);

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c32:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104c36:	81 7d f4 74 53 11 80 	cmpl   $0x80115374,-0xc(%ebp)
80104c3d:	0f 82 70 ff ff ff    	jb     80104bb3 <scheduler+0x82>
      proc = 0;

			// Process is done running
      break;
    }
    release(&ptable.lock);
80104c43:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104c4a:	e8 5e 04 00 00       	call   801050ad <release>

  }
80104c4f:	e9 ea fe ff ff       	jmp    80104b3e <scheduler+0xd>

80104c54 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c54:	55                   	push   %ebp
80104c55:	89 e5                	mov    %esp,%ebp
80104c57:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c5a:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104c61:	e8 0f 05 00 00       	call   80105175 <holding>
80104c66:	85 c0                	test   %eax,%eax
80104c68:	75 0c                	jne    80104c76 <sched+0x22>
    panic("sched ptable.lock");
80104c6a:	c7 04 24 5d 8c 10 80 	movl   $0x80108c5d,(%esp)
80104c71:	e8 61 b9 ff ff       	call   801005d7 <panic>
  if(cpu->ncli != 1)
80104c76:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c7c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c82:	83 f8 01             	cmp    $0x1,%eax
80104c85:	74 0c                	je     80104c93 <sched+0x3f>
    panic("sched locks");
80104c87:	c7 04 24 6f 8c 10 80 	movl   $0x80108c6f,(%esp)
80104c8e:	e8 44 b9 ff ff       	call   801005d7 <panic>
  if(proc->state == RUNNING)
80104c93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c99:	8b 40 0c             	mov    0xc(%eax),%eax
80104c9c:	83 f8 04             	cmp    $0x4,%eax
80104c9f:	75 0c                	jne    80104cad <sched+0x59>
    panic("sched running");
80104ca1:	c7 04 24 7b 8c 10 80 	movl   $0x80108c7b,(%esp)
80104ca8:	e8 2a b9 ff ff       	call   801005d7 <panic>
  if(readeflags()&FL_IF)
80104cad:	e8 c0 f7 ff ff       	call   80104472 <readeflags>
80104cb2:	25 00 02 00 00       	and    $0x200,%eax
80104cb7:	85 c0                	test   %eax,%eax
80104cb9:	74 0c                	je     80104cc7 <sched+0x73>
    panic("sched interruptible");
80104cbb:	c7 04 24 89 8c 10 80 	movl   $0x80108c89,(%esp)
80104cc2:	e8 10 b9 ff ff       	call   801005d7 <panic>
  intena = cpu->intena;
80104cc7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ccd:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104cd6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cdc:	8b 40 04             	mov    0x4(%eax),%eax
80104cdf:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ce6:	83 c2 1c             	add    $0x1c,%edx
80104ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ced:	89 14 24             	mov    %edx,(%esp)
80104cf0:	e8 3b 08 00 00       	call   80105530 <swtch>
  cpu->intena = intena;
80104cf5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cfe:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d04:	c9                   	leave  
80104d05:	c3                   	ret    

80104d06 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d06:	55                   	push   %ebp
80104d07:	89 e5                	mov    %esp,%ebp
80104d09:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d0c:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104d13:	e8 33 03 00 00       	call   8010504b <acquire>
  proc->state = RUNNABLE;
80104d18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d1e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d25:	e8 2a ff ff ff       	call   80104c54 <sched>
  release(&ptable.lock);
80104d2a:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104d31:	e8 77 03 00 00       	call   801050ad <release>
}
80104d36:	c9                   	leave  
80104d37:	c3                   	ret    

80104d38 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d38:	55                   	push   %ebp
80104d39:	89 e5                	mov    %esp,%ebp
80104d3b:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d3e:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104d45:	e8 63 03 00 00       	call   801050ad <release>

  if (first) {
80104d4a:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d4f:	85 c0                	test   %eax,%eax
80104d51:	74 22                	je     80104d75 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d53:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d5a:	00 00 00 
    iinit(ROOTDEV);
80104d5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104d64:	e8 e0 c8 ff ff       	call   80101649 <iinit>
    initlog(ROOTDEV);
80104d69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104d70:	e8 38 e6 ff ff       	call   801033ad <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d75:	c9                   	leave  
80104d76:	c3                   	ret    

80104d77 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d77:	55                   	push   %ebp
80104d78:	89 e5                	mov    %esp,%ebp
80104d7a:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104d7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d83:	85 c0                	test   %eax,%eax
80104d85:	75 0c                	jne    80104d93 <sleep+0x1c>
    panic("sleep");
80104d87:	c7 04 24 9d 8c 10 80 	movl   $0x80108c9d,(%esp)
80104d8e:	e8 44 b8 ff ff       	call   801005d7 <panic>

  if(lk == 0)
80104d93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d97:	75 0c                	jne    80104da5 <sleep+0x2e>
    panic("sleep without lk");
80104d99:	c7 04 24 a3 8c 10 80 	movl   $0x80108ca3,(%esp)
80104da0:	e8 32 b8 ff ff       	call   801005d7 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104da5:	81 7d 0c 40 33 11 80 	cmpl   $0x80113340,0xc(%ebp)
80104dac:	74 17                	je     80104dc5 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104dae:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104db5:	e8 91 02 00 00       	call   8010504b <acquire>
    release(lk);
80104dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dbd:	89 04 24             	mov    %eax,(%esp)
80104dc0:	e8 e8 02 00 00       	call   801050ad <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104dc5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dcb:	8b 55 08             	mov    0x8(%ebp),%edx
80104dce:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104dd1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104dde:	e8 71 fe ff ff       	call   80104c54 <sched>

  // Tidy up.
  proc->chan = 0;
80104de3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de9:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104df0:	81 7d 0c 40 33 11 80 	cmpl   $0x80113340,0xc(%ebp)
80104df7:	74 17                	je     80104e10 <sleep+0x99>
    release(&ptable.lock);
80104df9:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104e00:	e8 a8 02 00 00       	call   801050ad <release>
    acquire(lk);
80104e05:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e08:	89 04 24             	mov    %eax,(%esp)
80104e0b:	e8 3b 02 00 00       	call   8010504b <acquire>
  }
}
80104e10:	c9                   	leave  
80104e11:	c3                   	ret    

80104e12 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e12:	55                   	push   %ebp
80104e13:	89 e5                	mov    %esp,%ebp
80104e15:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e18:	c7 45 fc 74 33 11 80 	movl   $0x80113374,-0x4(%ebp)
80104e1f:	eb 24                	jmp    80104e45 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104e21:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e24:	8b 40 0c             	mov    0xc(%eax),%eax
80104e27:	83 f8 02             	cmp    $0x2,%eax
80104e2a:	75 15                	jne    80104e41 <wakeup1+0x2f>
80104e2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e2f:	8b 40 20             	mov    0x20(%eax),%eax
80104e32:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e35:	75 0a                	jne    80104e41 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e3a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e41:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104e45:	81 7d fc 74 53 11 80 	cmpl   $0x80115374,-0x4(%ebp)
80104e4c:	72 d3                	jb     80104e21 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104e4e:	c9                   	leave  
80104e4f:	c3                   	ret    

80104e50 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e50:	55                   	push   %ebp
80104e51:	89 e5                	mov    %esp,%ebp
80104e53:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104e56:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104e5d:	e8 e9 01 00 00       	call   8010504b <acquire>
  wakeup1(chan);
80104e62:	8b 45 08             	mov    0x8(%ebp),%eax
80104e65:	89 04 24             	mov    %eax,(%esp)
80104e68:	e8 a5 ff ff ff       	call   80104e12 <wakeup1>
  release(&ptable.lock);
80104e6d:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104e74:	e8 34 02 00 00       	call   801050ad <release>
}
80104e79:	c9                   	leave  
80104e7a:	c3                   	ret    

80104e7b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e7b:	55                   	push   %ebp
80104e7c:	89 e5                	mov    %esp,%ebp
80104e7e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e81:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104e88:	e8 be 01 00 00       	call   8010504b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e8d:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
80104e94:	eb 41                	jmp    80104ed7 <kill+0x5c>
    if(p->pid == pid){
80104e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e99:	8b 40 10             	mov    0x10(%eax),%eax
80104e9c:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e9f:	75 32                	jne    80104ed3 <kill+0x58>
      p->killed = 1;
80104ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eae:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb1:	83 f8 02             	cmp    $0x2,%eax
80104eb4:	75 0a                	jne    80104ec0 <kill+0x45>
        p->state = RUNNABLE;
80104eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ec0:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104ec7:	e8 e1 01 00 00       	call   801050ad <release>
      return 0;
80104ecc:	b8 00 00 00 00       	mov    $0x0,%eax
80104ed1:	eb 1e                	jmp    80104ef1 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ed3:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104ed7:	81 7d f4 74 53 11 80 	cmpl   $0x80115374,-0xc(%ebp)
80104ede:	72 b6                	jb     80104e96 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104ee0:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80104ee7:	e8 c1 01 00 00       	call   801050ad <release>
  return -1;
80104eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ef1:	c9                   	leave  
80104ef2:	c3                   	ret    

80104ef3 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ef3:	55                   	push   %ebp
80104ef4:	89 e5                	mov    %esp,%ebp
80104ef6:	83 ec 68             	sub    $0x68,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ef9:	c7 45 f0 74 33 11 80 	movl   $0x80113374,-0x10(%ebp)
80104f00:	e9 e0 00 00 00       	jmp    80104fe5 <procdump+0xf2>
    if(p->state == UNUSED)
80104f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f08:	8b 40 0c             	mov    0xc(%eax),%eax
80104f0b:	85 c0                	test   %eax,%eax
80104f0d:	75 05                	jne    80104f14 <procdump+0x21>
      continue;
80104f0f:	e9 cd 00 00 00       	jmp    80104fe1 <procdump+0xee>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f17:	8b 40 0c             	mov    0xc(%eax),%eax
80104f1a:	83 f8 05             	cmp    $0x5,%eax
80104f1d:	77 23                	ja     80104f42 <procdump+0x4f>
80104f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f22:	8b 40 0c             	mov    0xc(%eax),%eax
80104f25:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f2c:	85 c0                	test   %eax,%eax
80104f2e:	74 12                	je     80104f42 <procdump+0x4f>
      state = states[p->state];
80104f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f33:	8b 40 0c             	mov    0xc(%eax),%eax
80104f36:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f40:	eb 07                	jmp    80104f49 <procdump+0x56>
    else
      state = "???";
80104f42:	c7 45 ec b4 8c 10 80 	movl   $0x80108cb4,-0x14(%ebp)
    cprintf("%d %s %s %s", p->pid, state, p->name, p->tickets);
80104f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4c:	8b 50 7c             	mov    0x7c(%eax),%edx
80104f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f52:	8d 48 6c             	lea    0x6c(%eax),%ecx
80104f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f58:	8b 40 10             	mov    0x10(%eax),%eax
80104f5b:	89 54 24 10          	mov    %edx,0x10(%esp)
80104f5f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80104f63:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f66:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f6e:	c7 04 24 b8 8c 10 80 	movl   $0x80108cb8,(%esp)
80104f75:	e8 89 b4 ff ff       	call   80100403 <cprintf>
    if(p->state == SLEEPING){
80104f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f7d:	8b 40 0c             	mov    0xc(%eax),%eax
80104f80:	83 f8 02             	cmp    $0x2,%eax
80104f83:	75 50                	jne    80104fd5 <procdump+0xe2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f88:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f8b:	8b 40 0c             	mov    0xc(%eax),%eax
80104f8e:	83 c0 08             	add    $0x8,%eax
80104f91:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f94:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f98:	89 04 24             	mov    %eax,(%esp)
80104f9b:	e8 5c 01 00 00       	call   801050fc <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104fa0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fa7:	eb 1b                	jmp    80104fc4 <procdump+0xd1>
        cprintf(" %p", pc[i]);
80104fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fac:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fb4:	c7 04 24 c4 8c 10 80 	movl   $0x80108cc4,(%esp)
80104fbb:	e8 43 b4 ff ff       	call   80100403 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s %s", p->pid, state, p->name, p->tickets);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104fc0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fc4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104fc8:	7f 0b                	jg     80104fd5 <procdump+0xe2>
80104fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcd:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fd1:	85 c0                	test   %eax,%eax
80104fd3:	75 d4                	jne    80104fa9 <procdump+0xb6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104fd5:	c7 04 24 c8 8c 10 80 	movl   $0x80108cc8,(%esp)
80104fdc:	e8 22 b4 ff ff       	call   80100403 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fe1:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104fe5:	81 7d f0 74 53 11 80 	cmpl   $0x80115374,-0x10(%ebp)
80104fec:	0f 82 13 ff ff ff    	jb     80104f05 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104ff2:	c9                   	leave  
80104ff3:	c3                   	ret    

80104ff4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ff4:	55                   	push   %ebp
80104ff5:	89 e5                	mov    %esp,%ebp
80104ff7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ffa:	9c                   	pushf  
80104ffb:	58                   	pop    %eax
80104ffc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104fff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105002:	c9                   	leave  
80105003:	c3                   	ret    

80105004 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105004:	55                   	push   %ebp
80105005:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105007:	fa                   	cli    
}
80105008:	5d                   	pop    %ebp
80105009:	c3                   	ret    

8010500a <sti>:

static inline void
sti(void)
{
8010500a:	55                   	push   %ebp
8010500b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010500d:	fb                   	sti    
}
8010500e:	5d                   	pop    %ebp
8010500f:	c3                   	ret    

80105010 <xchg>:
    return ret;
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105010:	55                   	push   %ebp
80105011:	89 e5                	mov    %esp,%ebp
80105013:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105016:	8b 55 08             	mov    0x8(%ebp),%edx
80105019:	8b 45 0c             	mov    0xc(%ebp),%eax
8010501c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010501f:	f0 87 02             	lock xchg %eax,(%edx)
80105022:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105025:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105028:	c9                   	leave  
80105029:	c3                   	ret    

8010502a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010502a:	55                   	push   %ebp
8010502b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010502d:	8b 45 08             	mov    0x8(%ebp),%eax
80105030:	8b 55 0c             	mov    0xc(%ebp),%edx
80105033:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105036:	8b 45 08             	mov    0x8(%ebp),%eax
80105039:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010503f:	8b 45 08             	mov    0x8(%ebp),%eax
80105042:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105049:	5d                   	pop    %ebp
8010504a:	c3                   	ret    

8010504b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010504b:	55                   	push   %ebp
8010504c:	89 e5                	mov    %esp,%ebp
8010504e:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105051:	e8 49 01 00 00       	call   8010519f <pushcli>
  if(holding(lk))
80105056:	8b 45 08             	mov    0x8(%ebp),%eax
80105059:	89 04 24             	mov    %eax,(%esp)
8010505c:	e8 14 01 00 00       	call   80105175 <holding>
80105061:	85 c0                	test   %eax,%eax
80105063:	74 0c                	je     80105071 <acquire+0x26>
    panic("acquire");
80105065:	c7 04 24 f4 8c 10 80 	movl   $0x80108cf4,(%esp)
8010506c:	e8 66 b5 ff ff       	call   801005d7 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105071:	90                   	nop
80105072:	8b 45 08             	mov    0x8(%ebp),%eax
80105075:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010507c:	00 
8010507d:	89 04 24             	mov    %eax,(%esp)
80105080:	e8 8b ff ff ff       	call   80105010 <xchg>
80105085:	85 c0                	test   %eax,%eax
80105087:	75 e9                	jne    80105072 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105089:	8b 45 08             	mov    0x8(%ebp),%eax
8010508c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105093:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105096:	8b 45 08             	mov    0x8(%ebp),%eax
80105099:	83 c0 0c             	add    $0xc,%eax
8010509c:	89 44 24 04          	mov    %eax,0x4(%esp)
801050a0:	8d 45 08             	lea    0x8(%ebp),%eax
801050a3:	89 04 24             	mov    %eax,(%esp)
801050a6:	e8 51 00 00 00       	call   801050fc <getcallerpcs>
}
801050ab:	c9                   	leave  
801050ac:	c3                   	ret    

801050ad <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050ad:	55                   	push   %ebp
801050ae:	89 e5                	mov    %esp,%ebp
801050b0:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801050b3:	8b 45 08             	mov    0x8(%ebp),%eax
801050b6:	89 04 24             	mov    %eax,(%esp)
801050b9:	e8 b7 00 00 00       	call   80105175 <holding>
801050be:	85 c0                	test   %eax,%eax
801050c0:	75 0c                	jne    801050ce <release+0x21>
    panic("release");
801050c2:	c7 04 24 fc 8c 10 80 	movl   $0x80108cfc,(%esp)
801050c9:	e8 09 b5 ff ff       	call   801005d7 <panic>

  lk->pcs[0] = 0;
801050ce:	8b 45 08             	mov    0x8(%ebp),%eax
801050d1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050d8:	8b 45 08             	mov    0x8(%ebp),%eax
801050db:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801050e2:	8b 45 08             	mov    0x8(%ebp),%eax
801050e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801050ec:	00 
801050ed:	89 04 24             	mov    %eax,(%esp)
801050f0:	e8 1b ff ff ff       	call   80105010 <xchg>

  popcli();
801050f5:	e8 e9 00 00 00       	call   801051e3 <popcli>
}
801050fa:	c9                   	leave  
801050fb:	c3                   	ret    

801050fc <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050fc:	55                   	push   %ebp
801050fd:	89 e5                	mov    %esp,%ebp
801050ff:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105102:	8b 45 08             	mov    0x8(%ebp),%eax
80105105:	83 e8 08             	sub    $0x8,%eax
80105108:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010510b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105112:	eb 38                	jmp    8010514c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105114:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105118:	74 38                	je     80105152 <getcallerpcs+0x56>
8010511a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105121:	76 2f                	jbe    80105152 <getcallerpcs+0x56>
80105123:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105127:	74 29                	je     80105152 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105129:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010512c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105133:	8b 45 0c             	mov    0xc(%ebp),%eax
80105136:	01 c2                	add    %eax,%edx
80105138:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010513b:	8b 40 04             	mov    0x4(%eax),%eax
8010513e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105140:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105143:	8b 00                	mov    (%eax),%eax
80105145:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105148:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010514c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105150:	7e c2                	jle    80105114 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105152:	eb 19                	jmp    8010516d <getcallerpcs+0x71>
    pcs[i] = 0;
80105154:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105157:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010515e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105161:	01 d0                	add    %edx,%eax
80105163:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105169:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010516d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105171:	7e e1                	jle    80105154 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105173:	c9                   	leave  
80105174:	c3                   	ret    

80105175 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105175:	55                   	push   %ebp
80105176:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105178:	8b 45 08             	mov    0x8(%ebp),%eax
8010517b:	8b 00                	mov    (%eax),%eax
8010517d:	85 c0                	test   %eax,%eax
8010517f:	74 17                	je     80105198 <holding+0x23>
80105181:	8b 45 08             	mov    0x8(%ebp),%eax
80105184:	8b 50 08             	mov    0x8(%eax),%edx
80105187:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010518d:	39 c2                	cmp    %eax,%edx
8010518f:	75 07                	jne    80105198 <holding+0x23>
80105191:	b8 01 00 00 00       	mov    $0x1,%eax
80105196:	eb 05                	jmp    8010519d <holding+0x28>
80105198:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010519d:	5d                   	pop    %ebp
8010519e:	c3                   	ret    

8010519f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010519f:	55                   	push   %ebp
801051a0:	89 e5                	mov    %esp,%ebp
801051a2:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051a5:	e8 4a fe ff ff       	call   80104ff4 <readeflags>
801051aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801051ad:	e8 52 fe ff ff       	call   80105004 <cli>
  if(cpu->ncli++ == 0)
801051b2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051b9:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801051bf:	8d 48 01             	lea    0x1(%eax),%ecx
801051c2:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801051c8:	85 c0                	test   %eax,%eax
801051ca:	75 15                	jne    801051e1 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801051cc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051d5:	81 e2 00 02 00 00    	and    $0x200,%edx
801051db:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801051e1:	c9                   	leave  
801051e2:	c3                   	ret    

801051e3 <popcli>:

void
popcli(void)
{
801051e3:	55                   	push   %ebp
801051e4:	89 e5                	mov    %esp,%ebp
801051e6:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801051e9:	e8 06 fe ff ff       	call   80104ff4 <readeflags>
801051ee:	25 00 02 00 00       	and    $0x200,%eax
801051f3:	85 c0                	test   %eax,%eax
801051f5:	74 0c                	je     80105203 <popcli+0x20>
    panic("popcli - interruptible");
801051f7:	c7 04 24 04 8d 10 80 	movl   $0x80108d04,(%esp)
801051fe:	e8 d4 b3 ff ff       	call   801005d7 <panic>
  if(--cpu->ncli < 0)
80105203:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105209:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010520f:	83 ea 01             	sub    $0x1,%edx
80105212:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105218:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010521e:	85 c0                	test   %eax,%eax
80105220:	79 0c                	jns    8010522e <popcli+0x4b>
    panic("popcli");
80105222:	c7 04 24 1b 8d 10 80 	movl   $0x80108d1b,(%esp)
80105229:	e8 a9 b3 ff ff       	call   801005d7 <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010522e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105234:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010523a:	85 c0                	test   %eax,%eax
8010523c:	75 15                	jne    80105253 <popcli+0x70>
8010523e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105244:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010524a:	85 c0                	test   %eax,%eax
8010524c:	74 05                	je     80105253 <popcli+0x70>
    sti();
8010524e:	e8 b7 fd ff ff       	call   8010500a <sti>
}
80105253:	c9                   	leave  
80105254:	c3                   	ret    

80105255 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105255:	55                   	push   %ebp
80105256:	89 e5                	mov    %esp,%ebp
80105258:	57                   	push   %edi
80105259:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010525a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010525d:	8b 55 10             	mov    0x10(%ebp),%edx
80105260:	8b 45 0c             	mov    0xc(%ebp),%eax
80105263:	89 cb                	mov    %ecx,%ebx
80105265:	89 df                	mov    %ebx,%edi
80105267:	89 d1                	mov    %edx,%ecx
80105269:	fc                   	cld    
8010526a:	f3 aa                	rep stos %al,%es:(%edi)
8010526c:	89 ca                	mov    %ecx,%edx
8010526e:	89 fb                	mov    %edi,%ebx
80105270:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105273:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105276:	5b                   	pop    %ebx
80105277:	5f                   	pop    %edi
80105278:	5d                   	pop    %ebp
80105279:	c3                   	ret    

8010527a <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010527a:	55                   	push   %ebp
8010527b:	89 e5                	mov    %esp,%ebp
8010527d:	57                   	push   %edi
8010527e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010527f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105282:	8b 55 10             	mov    0x10(%ebp),%edx
80105285:	8b 45 0c             	mov    0xc(%ebp),%eax
80105288:	89 cb                	mov    %ecx,%ebx
8010528a:	89 df                	mov    %ebx,%edi
8010528c:	89 d1                	mov    %edx,%ecx
8010528e:	fc                   	cld    
8010528f:	f3 ab                	rep stos %eax,%es:(%edi)
80105291:	89 ca                	mov    %ecx,%edx
80105293:	89 fb                	mov    %edi,%ebx
80105295:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105298:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010529b:	5b                   	pop    %ebx
8010529c:	5f                   	pop    %edi
8010529d:	5d                   	pop    %ebp
8010529e:	c3                   	ret    

8010529f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010529f:	55                   	push   %ebp
801052a0:	89 e5                	mov    %esp,%ebp
801052a2:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801052a5:	8b 45 08             	mov    0x8(%ebp),%eax
801052a8:	83 e0 03             	and    $0x3,%eax
801052ab:	85 c0                	test   %eax,%eax
801052ad:	75 49                	jne    801052f8 <memset+0x59>
801052af:	8b 45 10             	mov    0x10(%ebp),%eax
801052b2:	83 e0 03             	and    $0x3,%eax
801052b5:	85 c0                	test   %eax,%eax
801052b7:	75 3f                	jne    801052f8 <memset+0x59>
    c &= 0xFF;
801052b9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801052c0:	8b 45 10             	mov    0x10(%ebp),%eax
801052c3:	c1 e8 02             	shr    $0x2,%eax
801052c6:	89 c2                	mov    %eax,%edx
801052c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052cb:	c1 e0 18             	shl    $0x18,%eax
801052ce:	89 c1                	mov    %eax,%ecx
801052d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d3:	c1 e0 10             	shl    $0x10,%eax
801052d6:	09 c1                	or     %eax,%ecx
801052d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052db:	c1 e0 08             	shl    $0x8,%eax
801052de:	09 c8                	or     %ecx,%eax
801052e0:	0b 45 0c             	or     0xc(%ebp),%eax
801052e3:	89 54 24 08          	mov    %edx,0x8(%esp)
801052e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801052eb:	8b 45 08             	mov    0x8(%ebp),%eax
801052ee:	89 04 24             	mov    %eax,(%esp)
801052f1:	e8 84 ff ff ff       	call   8010527a <stosl>
801052f6:	eb 19                	jmp    80105311 <memset+0x72>
  } else
    stosb(dst, c, n);
801052f8:	8b 45 10             	mov    0x10(%ebp),%eax
801052fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801052ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105302:	89 44 24 04          	mov    %eax,0x4(%esp)
80105306:	8b 45 08             	mov    0x8(%ebp),%eax
80105309:	89 04 24             	mov    %eax,(%esp)
8010530c:	e8 44 ff ff ff       	call   80105255 <stosb>
  return dst;
80105311:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105314:	c9                   	leave  
80105315:	c3                   	ret    

80105316 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105316:	55                   	push   %ebp
80105317:	89 e5                	mov    %esp,%ebp
80105319:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010531c:	8b 45 08             	mov    0x8(%ebp),%eax
8010531f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105322:	8b 45 0c             	mov    0xc(%ebp),%eax
80105325:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105328:	eb 30                	jmp    8010535a <memcmp+0x44>
    if(*s1 != *s2)
8010532a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010532d:	0f b6 10             	movzbl (%eax),%edx
80105330:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105333:	0f b6 00             	movzbl (%eax),%eax
80105336:	38 c2                	cmp    %al,%dl
80105338:	74 18                	je     80105352 <memcmp+0x3c>
      return *s1 - *s2;
8010533a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010533d:	0f b6 00             	movzbl (%eax),%eax
80105340:	0f b6 d0             	movzbl %al,%edx
80105343:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105346:	0f b6 00             	movzbl (%eax),%eax
80105349:	0f b6 c0             	movzbl %al,%eax
8010534c:	29 c2                	sub    %eax,%edx
8010534e:	89 d0                	mov    %edx,%eax
80105350:	eb 1a                	jmp    8010536c <memcmp+0x56>
    s1++, s2++;
80105352:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105356:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010535a:	8b 45 10             	mov    0x10(%ebp),%eax
8010535d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105360:	89 55 10             	mov    %edx,0x10(%ebp)
80105363:	85 c0                	test   %eax,%eax
80105365:	75 c3                	jne    8010532a <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105367:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010536c:	c9                   	leave  
8010536d:	c3                   	ret    

8010536e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010536e:	55                   	push   %ebp
8010536f:	89 e5                	mov    %esp,%ebp
80105371:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105374:	8b 45 0c             	mov    0xc(%ebp),%eax
80105377:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010537a:	8b 45 08             	mov    0x8(%ebp),%eax
8010537d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105380:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105383:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105386:	73 3d                	jae    801053c5 <memmove+0x57>
80105388:	8b 45 10             	mov    0x10(%ebp),%eax
8010538b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010538e:	01 d0                	add    %edx,%eax
80105390:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105393:	76 30                	jbe    801053c5 <memmove+0x57>
    s += n;
80105395:	8b 45 10             	mov    0x10(%ebp),%eax
80105398:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010539b:	8b 45 10             	mov    0x10(%ebp),%eax
8010539e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053a1:	eb 13                	jmp    801053b6 <memmove+0x48>
      *--d = *--s;
801053a3:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053a7:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ae:	0f b6 10             	movzbl (%eax),%edx
801053b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b4:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801053b6:	8b 45 10             	mov    0x10(%ebp),%eax
801053b9:	8d 50 ff             	lea    -0x1(%eax),%edx
801053bc:	89 55 10             	mov    %edx,0x10(%ebp)
801053bf:	85 c0                	test   %eax,%eax
801053c1:	75 e0                	jne    801053a3 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801053c3:	eb 26                	jmp    801053eb <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053c5:	eb 17                	jmp    801053de <memmove+0x70>
      *d++ = *s++;
801053c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053ca:	8d 50 01             	lea    0x1(%eax),%edx
801053cd:	89 55 f8             	mov    %edx,-0x8(%ebp)
801053d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053d3:	8d 4a 01             	lea    0x1(%edx),%ecx
801053d6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801053d9:	0f b6 12             	movzbl (%edx),%edx
801053dc:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053de:	8b 45 10             	mov    0x10(%ebp),%eax
801053e1:	8d 50 ff             	lea    -0x1(%eax),%edx
801053e4:	89 55 10             	mov    %edx,0x10(%ebp)
801053e7:	85 c0                	test   %eax,%eax
801053e9:	75 dc                	jne    801053c7 <memmove+0x59>
      *d++ = *s++;

  return dst;
801053eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053ee:	c9                   	leave  
801053ef:	c3                   	ret    

801053f0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053f0:	55                   	push   %ebp
801053f1:	89 e5                	mov    %esp,%ebp
801053f3:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801053f6:	8b 45 10             	mov    0x10(%ebp),%eax
801053f9:	89 44 24 08          	mov    %eax,0x8(%esp)
801053fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105400:	89 44 24 04          	mov    %eax,0x4(%esp)
80105404:	8b 45 08             	mov    0x8(%ebp),%eax
80105407:	89 04 24             	mov    %eax,(%esp)
8010540a:	e8 5f ff ff ff       	call   8010536e <memmove>
}
8010540f:	c9                   	leave  
80105410:	c3                   	ret    

80105411 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105411:	55                   	push   %ebp
80105412:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105414:	eb 0c                	jmp    80105422 <strncmp+0x11>
    n--, p++, q++;
80105416:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010541a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010541e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105422:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105426:	74 1a                	je     80105442 <strncmp+0x31>
80105428:	8b 45 08             	mov    0x8(%ebp),%eax
8010542b:	0f b6 00             	movzbl (%eax),%eax
8010542e:	84 c0                	test   %al,%al
80105430:	74 10                	je     80105442 <strncmp+0x31>
80105432:	8b 45 08             	mov    0x8(%ebp),%eax
80105435:	0f b6 10             	movzbl (%eax),%edx
80105438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543b:	0f b6 00             	movzbl (%eax),%eax
8010543e:	38 c2                	cmp    %al,%dl
80105440:	74 d4                	je     80105416 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105442:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105446:	75 07                	jne    8010544f <strncmp+0x3e>
    return 0;
80105448:	b8 00 00 00 00       	mov    $0x0,%eax
8010544d:	eb 16                	jmp    80105465 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010544f:	8b 45 08             	mov    0x8(%ebp),%eax
80105452:	0f b6 00             	movzbl (%eax),%eax
80105455:	0f b6 d0             	movzbl %al,%edx
80105458:	8b 45 0c             	mov    0xc(%ebp),%eax
8010545b:	0f b6 00             	movzbl (%eax),%eax
8010545e:	0f b6 c0             	movzbl %al,%eax
80105461:	29 c2                	sub    %eax,%edx
80105463:	89 d0                	mov    %edx,%eax
}
80105465:	5d                   	pop    %ebp
80105466:	c3                   	ret    

80105467 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105467:	55                   	push   %ebp
80105468:	89 e5                	mov    %esp,%ebp
8010546a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010546d:	8b 45 08             	mov    0x8(%ebp),%eax
80105470:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105473:	90                   	nop
80105474:	8b 45 10             	mov    0x10(%ebp),%eax
80105477:	8d 50 ff             	lea    -0x1(%eax),%edx
8010547a:	89 55 10             	mov    %edx,0x10(%ebp)
8010547d:	85 c0                	test   %eax,%eax
8010547f:	7e 1e                	jle    8010549f <strncpy+0x38>
80105481:	8b 45 08             	mov    0x8(%ebp),%eax
80105484:	8d 50 01             	lea    0x1(%eax),%edx
80105487:	89 55 08             	mov    %edx,0x8(%ebp)
8010548a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010548d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105490:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105493:	0f b6 12             	movzbl (%edx),%edx
80105496:	88 10                	mov    %dl,(%eax)
80105498:	0f b6 00             	movzbl (%eax),%eax
8010549b:	84 c0                	test   %al,%al
8010549d:	75 d5                	jne    80105474 <strncpy+0xd>
    ;
  while(n-- > 0)
8010549f:	eb 0c                	jmp    801054ad <strncpy+0x46>
    *s++ = 0;
801054a1:	8b 45 08             	mov    0x8(%ebp),%eax
801054a4:	8d 50 01             	lea    0x1(%eax),%edx
801054a7:	89 55 08             	mov    %edx,0x8(%ebp)
801054aa:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801054ad:	8b 45 10             	mov    0x10(%ebp),%eax
801054b0:	8d 50 ff             	lea    -0x1(%eax),%edx
801054b3:	89 55 10             	mov    %edx,0x10(%ebp)
801054b6:	85 c0                	test   %eax,%eax
801054b8:	7f e7                	jg     801054a1 <strncpy+0x3a>
    *s++ = 0;
  return os;
801054ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054bd:	c9                   	leave  
801054be:	c3                   	ret    

801054bf <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054bf:	55                   	push   %ebp
801054c0:	89 e5                	mov    %esp,%ebp
801054c2:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054c5:	8b 45 08             	mov    0x8(%ebp),%eax
801054c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054cf:	7f 05                	jg     801054d6 <safestrcpy+0x17>
    return os;
801054d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d4:	eb 31                	jmp    80105507 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801054d6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054de:	7e 1e                	jle    801054fe <safestrcpy+0x3f>
801054e0:	8b 45 08             	mov    0x8(%ebp),%eax
801054e3:	8d 50 01             	lea    0x1(%eax),%edx
801054e6:	89 55 08             	mov    %edx,0x8(%ebp)
801054e9:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ec:	8d 4a 01             	lea    0x1(%edx),%ecx
801054ef:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054f2:	0f b6 12             	movzbl (%edx),%edx
801054f5:	88 10                	mov    %dl,(%eax)
801054f7:	0f b6 00             	movzbl (%eax),%eax
801054fa:	84 c0                	test   %al,%al
801054fc:	75 d8                	jne    801054d6 <safestrcpy+0x17>
    ;
  *s = 0;
801054fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105501:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105504:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105507:	c9                   	leave  
80105508:	c3                   	ret    

80105509 <strlen>:

int
strlen(const char *s)
{
80105509:	55                   	push   %ebp
8010550a:	89 e5                	mov    %esp,%ebp
8010550c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010550f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105516:	eb 04                	jmp    8010551c <strlen+0x13>
80105518:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010551c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010551f:	8b 45 08             	mov    0x8(%ebp),%eax
80105522:	01 d0                	add    %edx,%eax
80105524:	0f b6 00             	movzbl (%eax),%eax
80105527:	84 c0                	test   %al,%al
80105529:	75 ed                	jne    80105518 <strlen+0xf>
    ;
  return n;
8010552b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552e:	c9                   	leave  
8010552f:	c3                   	ret    

80105530 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105530:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105534:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105538:	55                   	push   %ebp
  pushl %ebx
80105539:	53                   	push   %ebx
  pushl %esi
8010553a:	56                   	push   %esi
  pushl %edi
8010553b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010553c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010553e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105540:	5f                   	pop    %edi
  popl %esi
80105541:	5e                   	pop    %esi
  popl %ebx
80105542:	5b                   	pop    %ebx
  popl %ebp
80105543:	5d                   	pop    %ebp
  ret
80105544:	c3                   	ret    

80105545 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105545:	55                   	push   %ebp
80105546:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105548:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010554e:	8b 00                	mov    (%eax),%eax
80105550:	3b 45 08             	cmp    0x8(%ebp),%eax
80105553:	76 12                	jbe    80105567 <fetchint+0x22>
80105555:	8b 45 08             	mov    0x8(%ebp),%eax
80105558:	8d 50 04             	lea    0x4(%eax),%edx
8010555b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105561:	8b 00                	mov    (%eax),%eax
80105563:	39 c2                	cmp    %eax,%edx
80105565:	76 07                	jbe    8010556e <fetchint+0x29>
    return -1;
80105567:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556c:	eb 0f                	jmp    8010557d <fetchint+0x38>
  *ip = *(int*)(addr);
8010556e:	8b 45 08             	mov    0x8(%ebp),%eax
80105571:	8b 10                	mov    (%eax),%edx
80105573:	8b 45 0c             	mov    0xc(%ebp),%eax
80105576:	89 10                	mov    %edx,(%eax)
  return 0;
80105578:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010557d:	5d                   	pop    %ebp
8010557e:	c3                   	ret    

8010557f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010557f:	55                   	push   %ebp
80105580:	89 e5                	mov    %esp,%ebp
80105582:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105585:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010558b:	8b 00                	mov    (%eax),%eax
8010558d:	3b 45 08             	cmp    0x8(%ebp),%eax
80105590:	77 07                	ja     80105599 <fetchstr+0x1a>
    return -1;
80105592:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105597:	eb 46                	jmp    801055df <fetchstr+0x60>
  *pp = (char*)addr;
80105599:	8b 55 08             	mov    0x8(%ebp),%edx
8010559c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559f:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801055a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055a7:	8b 00                	mov    (%eax),%eax
801055a9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801055ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801055af:	8b 00                	mov    (%eax),%eax
801055b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055b4:	eb 1c                	jmp    801055d2 <fetchstr+0x53>
    if(*s == 0)
801055b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b9:	0f b6 00             	movzbl (%eax),%eax
801055bc:	84 c0                	test   %al,%al
801055be:	75 0e                	jne    801055ce <fetchstr+0x4f>
      return s - *pp;
801055c0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c6:	8b 00                	mov    (%eax),%eax
801055c8:	29 c2                	sub    %eax,%edx
801055ca:	89 d0                	mov    %edx,%eax
801055cc:	eb 11                	jmp    801055df <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801055ce:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055d8:	72 dc                	jb     801055b6 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801055da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055df:	c9                   	leave  
801055e0:	c3                   	ret    

801055e1 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055e1:	55                   	push   %ebp
801055e2:	89 e5                	mov    %esp,%ebp
801055e4:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055ed:	8b 40 18             	mov    0x18(%eax),%eax
801055f0:	8b 50 44             	mov    0x44(%eax),%edx
801055f3:	8b 45 08             	mov    0x8(%ebp),%eax
801055f6:	c1 e0 02             	shl    $0x2,%eax
801055f9:	01 d0                	add    %edx,%eax
801055fb:	8d 50 04             	lea    0x4(%eax),%edx
801055fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105601:	89 44 24 04          	mov    %eax,0x4(%esp)
80105605:	89 14 24             	mov    %edx,(%esp)
80105608:	e8 38 ff ff ff       	call   80105545 <fetchint>
}
8010560d:	c9                   	leave  
8010560e:	c3                   	ret    

8010560f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010560f:	55                   	push   %ebp
80105610:	89 e5                	mov    %esp,%ebp
80105612:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105615:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105618:	89 44 24 04          	mov    %eax,0x4(%esp)
8010561c:	8b 45 08             	mov    0x8(%ebp),%eax
8010561f:	89 04 24             	mov    %eax,(%esp)
80105622:	e8 ba ff ff ff       	call   801055e1 <argint>
80105627:	85 c0                	test   %eax,%eax
80105629:	79 07                	jns    80105632 <argptr+0x23>
    return -1;
8010562b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105630:	eb 3d                	jmp    8010566f <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105632:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105635:	89 c2                	mov    %eax,%edx
80105637:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010563d:	8b 00                	mov    (%eax),%eax
8010563f:	39 c2                	cmp    %eax,%edx
80105641:	73 16                	jae    80105659 <argptr+0x4a>
80105643:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105646:	89 c2                	mov    %eax,%edx
80105648:	8b 45 10             	mov    0x10(%ebp),%eax
8010564b:	01 c2                	add    %eax,%edx
8010564d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105653:	8b 00                	mov    (%eax),%eax
80105655:	39 c2                	cmp    %eax,%edx
80105657:	76 07                	jbe    80105660 <argptr+0x51>
    return -1;
80105659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010565e:	eb 0f                	jmp    8010566f <argptr+0x60>
  *pp = (char*)i;
80105660:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105663:	89 c2                	mov    %eax,%edx
80105665:	8b 45 0c             	mov    0xc(%ebp),%eax
80105668:	89 10                	mov    %edx,(%eax)
  return 0;
8010566a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010566f:	c9                   	leave  
80105670:	c3                   	ret    

80105671 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105671:	55                   	push   %ebp
80105672:	89 e5                	mov    %esp,%ebp
80105674:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105677:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010567a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010567e:	8b 45 08             	mov    0x8(%ebp),%eax
80105681:	89 04 24             	mov    %eax,(%esp)
80105684:	e8 58 ff ff ff       	call   801055e1 <argint>
80105689:	85 c0                	test   %eax,%eax
8010568b:	79 07                	jns    80105694 <argstr+0x23>
    return -1;
8010568d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105692:	eb 12                	jmp    801056a6 <argstr+0x35>
  return fetchstr(addr, pp);
80105694:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105697:	8b 55 0c             	mov    0xc(%ebp),%edx
8010569a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010569e:	89 04 24             	mov    %eax,(%esp)
801056a1:	e8 d9 fe ff ff       	call   8010557f <fetchstr>
}
801056a6:	c9                   	leave  
801056a7:	c3                   	ret    

801056a8 <syscall>:
[SYS_settickets] sys_settickets,
};

void
syscall(void)
{
801056a8:	55                   	push   %ebp
801056a9:	89 e5                	mov    %esp,%ebp
801056ab:	53                   	push   %ebx
801056ac:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801056af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b5:	8b 40 18             	mov    0x18(%eax),%eax
801056b8:	8b 40 1c             	mov    0x1c(%eax),%eax
801056bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056c2:	7e 30                	jle    801056f4 <syscall+0x4c>
801056c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c7:	83 f8 17             	cmp    $0x17,%eax
801056ca:	77 28                	ja     801056f4 <syscall+0x4c>
801056cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056cf:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056d6:	85 c0                	test   %eax,%eax
801056d8:	74 1a                	je     801056f4 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801056da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e0:	8b 58 18             	mov    0x18(%eax),%ebx
801056e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e6:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056ed:	ff d0                	call   *%eax
801056ef:	89 43 1c             	mov    %eax,0x1c(%ebx)
801056f2:	eb 3d                	jmp    80105731 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056fa:	8d 48 6c             	lea    0x6c(%eax),%ecx
801056fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105703:	8b 40 10             	mov    0x10(%eax),%eax
80105706:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105709:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010570d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105711:	89 44 24 04          	mov    %eax,0x4(%esp)
80105715:	c7 04 24 22 8d 10 80 	movl   $0x80108d22,(%esp)
8010571c:	e8 e2 ac ff ff       	call   80100403 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105721:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105727:	8b 40 18             	mov    0x18(%eax),%eax
8010572a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105731:	83 c4 24             	add    $0x24,%esp
80105734:	5b                   	pop    %ebx
80105735:	5d                   	pop    %ebp
80105736:	c3                   	ret    

80105737 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105737:	55                   	push   %ebp
80105738:	89 e5                	mov    %esp,%ebp
8010573a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010573d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105740:	89 44 24 04          	mov    %eax,0x4(%esp)
80105744:	8b 45 08             	mov    0x8(%ebp),%eax
80105747:	89 04 24             	mov    %eax,(%esp)
8010574a:	e8 92 fe ff ff       	call   801055e1 <argint>
8010574f:	85 c0                	test   %eax,%eax
80105751:	79 07                	jns    8010575a <argfd+0x23>
    return -1;
80105753:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105758:	eb 50                	jmp    801057aa <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010575a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575d:	85 c0                	test   %eax,%eax
8010575f:	78 21                	js     80105782 <argfd+0x4b>
80105761:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105764:	83 f8 0f             	cmp    $0xf,%eax
80105767:	7f 19                	jg     80105782 <argfd+0x4b>
80105769:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010576f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105772:	83 c2 08             	add    $0x8,%edx
80105775:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105779:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010577c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105780:	75 07                	jne    80105789 <argfd+0x52>
    return -1;
80105782:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105787:	eb 21                	jmp    801057aa <argfd+0x73>
  if(pfd)
80105789:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010578d:	74 08                	je     80105797 <argfd+0x60>
    *pfd = fd;
8010578f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105792:	8b 45 0c             	mov    0xc(%ebp),%eax
80105795:	89 10                	mov    %edx,(%eax)
  if(pf)
80105797:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010579b:	74 08                	je     801057a5 <argfd+0x6e>
    *pf = f;
8010579d:	8b 45 10             	mov    0x10(%ebp),%eax
801057a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057a3:	89 10                	mov    %edx,(%eax)
  return 0;
801057a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057aa:	c9                   	leave  
801057ab:	c3                   	ret    

801057ac <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057ac:	55                   	push   %ebp
801057ad:	89 e5                	mov    %esp,%ebp
801057af:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057b9:	eb 30                	jmp    801057eb <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057c4:	83 c2 08             	add    $0x8,%edx
801057c7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057cb:	85 c0                	test   %eax,%eax
801057cd:	75 18                	jne    801057e7 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057d8:	8d 4a 08             	lea    0x8(%edx),%ecx
801057db:	8b 55 08             	mov    0x8(%ebp),%edx
801057de:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057e5:	eb 0f                	jmp    801057f6 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057eb:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057ef:	7e ca                	jle    801057bb <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801057f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057f6:	c9                   	leave  
801057f7:	c3                   	ret    

801057f8 <sys_dup>:

int
sys_dup(void)
{
801057f8:	55                   	push   %ebp
801057f9:	89 e5                	mov    %esp,%ebp
801057fb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105801:	89 44 24 08          	mov    %eax,0x8(%esp)
80105805:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010580c:	00 
8010580d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105814:	e8 1e ff ff ff       	call   80105737 <argfd>
80105819:	85 c0                	test   %eax,%eax
8010581b:	79 07                	jns    80105824 <sys_dup+0x2c>
    return -1;
8010581d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105822:	eb 29                	jmp    8010584d <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105824:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105827:	89 04 24             	mov    %eax,(%esp)
8010582a:	e8 7d ff ff ff       	call   801057ac <fdalloc>
8010582f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105832:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105836:	79 07                	jns    8010583f <sys_dup+0x47>
    return -1;
80105838:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583d:	eb 0e                	jmp    8010584d <sys_dup+0x55>
  filedup(f);
8010583f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105842:	89 04 24             	mov    %eax,(%esp)
80105845:	e8 f4 b7 ff ff       	call   8010103e <filedup>
  return fd;
8010584a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010584d:	c9                   	leave  
8010584e:	c3                   	ret    

8010584f <sys_read>:

int
sys_read(void)
{
8010584f:	55                   	push   %ebp
80105850:	89 e5                	mov    %esp,%ebp
80105852:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105855:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105858:	89 44 24 08          	mov    %eax,0x8(%esp)
8010585c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105863:	00 
80105864:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010586b:	e8 c7 fe ff ff       	call   80105737 <argfd>
80105870:	85 c0                	test   %eax,%eax
80105872:	78 35                	js     801058a9 <sys_read+0x5a>
80105874:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105877:	89 44 24 04          	mov    %eax,0x4(%esp)
8010587b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105882:	e8 5a fd ff ff       	call   801055e1 <argint>
80105887:	85 c0                	test   %eax,%eax
80105889:	78 1e                	js     801058a9 <sys_read+0x5a>
8010588b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105892:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105895:	89 44 24 04          	mov    %eax,0x4(%esp)
80105899:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058a0:	e8 6a fd ff ff       	call   8010560f <argptr>
801058a5:	85 c0                	test   %eax,%eax
801058a7:	79 07                	jns    801058b0 <sys_read+0x61>
    return -1;
801058a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ae:	eb 19                	jmp    801058c9 <sys_read+0x7a>
  return fileread(f, p, n);
801058b0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801058bd:	89 54 24 04          	mov    %edx,0x4(%esp)
801058c1:	89 04 24             	mov    %eax,(%esp)
801058c4:	e8 e2 b8 ff ff       	call   801011ab <fileread>
}
801058c9:	c9                   	leave  
801058ca:	c3                   	ret    

801058cb <sys_write>:

int
sys_write(void)
{
801058cb:	55                   	push   %ebp
801058cc:	89 e5                	mov    %esp,%ebp
801058ce:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801058d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058df:	00 
801058e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058e7:	e8 4b fe ff ff       	call   80105737 <argfd>
801058ec:	85 c0                	test   %eax,%eax
801058ee:	78 35                	js     80105925 <sys_write+0x5a>
801058f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801058fe:	e8 de fc ff ff       	call   801055e1 <argint>
80105903:	85 c0                	test   %eax,%eax
80105905:	78 1e                	js     80105925 <sys_write+0x5a>
80105907:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010590e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105911:	89 44 24 04          	mov    %eax,0x4(%esp)
80105915:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010591c:	e8 ee fc ff ff       	call   8010560f <argptr>
80105921:	85 c0                	test   %eax,%eax
80105923:	79 07                	jns    8010592c <sys_write+0x61>
    return -1;
80105925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592a:	eb 19                	jmp    80105945 <sys_write+0x7a>
  return filewrite(f, p, n);
8010592c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010592f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105935:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105939:	89 54 24 04          	mov    %edx,0x4(%esp)
8010593d:	89 04 24             	mov    %eax,(%esp)
80105940:	e8 22 b9 ff ff       	call   80101267 <filewrite>
}
80105945:	c9                   	leave  
80105946:	c3                   	ret    

80105947 <sys_close>:

int
sys_close(void)
{
80105947:	55                   	push   %ebp
80105948:	89 e5                	mov    %esp,%ebp
8010594a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010594d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105950:	89 44 24 08          	mov    %eax,0x8(%esp)
80105954:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105957:	89 44 24 04          	mov    %eax,0x4(%esp)
8010595b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105962:	e8 d0 fd ff ff       	call   80105737 <argfd>
80105967:	85 c0                	test   %eax,%eax
80105969:	79 07                	jns    80105972 <sys_close+0x2b>
    return -1;
8010596b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105970:	eb 24                	jmp    80105996 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105972:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105978:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010597b:	83 c2 08             	add    $0x8,%edx
8010597e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105985:	00 
  fileclose(f);
80105986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105989:	89 04 24             	mov    %eax,(%esp)
8010598c:	e8 f5 b6 ff ff       	call   80101086 <fileclose>
  return 0;
80105991:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105996:	c9                   	leave  
80105997:	c3                   	ret    

80105998 <sys_fstat>:

int
sys_fstat(void)
{
80105998:	55                   	push   %ebp
80105999:	89 e5                	mov    %esp,%ebp
8010599b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010599e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801059a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059ac:	00 
801059ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059b4:	e8 7e fd ff ff       	call   80105737 <argfd>
801059b9:	85 c0                	test   %eax,%eax
801059bb:	78 1f                	js     801059dc <sys_fstat+0x44>
801059bd:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801059c4:	00 
801059c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801059cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059d3:	e8 37 fc ff ff       	call   8010560f <argptr>
801059d8:	85 c0                	test   %eax,%eax
801059da:	79 07                	jns    801059e3 <sys_fstat+0x4b>
    return -1;
801059dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e1:	eb 12                	jmp    801059f5 <sys_fstat+0x5d>
  return filestat(f, st);
801059e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e9:	89 54 24 04          	mov    %edx,0x4(%esp)
801059ed:	89 04 24             	mov    %eax,(%esp)
801059f0:	e8 67 b7 ff ff       	call   8010115c <filestat>
}
801059f5:	c9                   	leave  
801059f6:	c3                   	ret    

801059f7 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059f7:	55                   	push   %ebp
801059f8:	89 e5                	mov    %esp,%ebp
801059fa:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059fd:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a00:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a0b:	e8 61 fc ff ff       	call   80105671 <argstr>
80105a10:	85 c0                	test   %eax,%eax
80105a12:	78 17                	js     80105a2b <sys_link+0x34>
80105a14:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a17:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a22:	e8 4a fc ff ff       	call   80105671 <argstr>
80105a27:	85 c0                	test   %eax,%eax
80105a29:	79 0a                	jns    80105a35 <sys_link+0x3e>
    return -1;
80105a2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a30:	e9 42 01 00 00       	jmp    80105b77 <sys_link+0x180>

  begin_op();
80105a35:	e8 77 db ff ff       	call   801035b1 <begin_op>
  if((ip = namei(old)) == 0){
80105a3a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a3d:	89 04 24             	mov    %eax,(%esp)
80105a40:	e8 dd ca ff ff       	call   80102522 <namei>
80105a45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a4c:	75 0f                	jne    80105a5d <sys_link+0x66>
    end_op();
80105a4e:	e8 e2 db ff ff       	call   80103635 <end_op>
    return -1;
80105a53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a58:	e9 1a 01 00 00       	jmp    80105b77 <sys_link+0x180>
  }

  ilock(ip);
80105a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a60:	89 04 24             	mov    %eax,(%esp)
80105a63:	e8 09 bf ff ff       	call   80101971 <ilock>
  if(ip->type == T_DIR){
80105a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a6f:	66 83 f8 01          	cmp    $0x1,%ax
80105a73:	75 1a                	jne    80105a8f <sys_link+0x98>
    iunlockput(ip);
80105a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a78:	89 04 24             	mov    %eax,(%esp)
80105a7b:	e8 7b c1 ff ff       	call   80101bfb <iunlockput>
    end_op();
80105a80:	e8 b0 db ff ff       	call   80103635 <end_op>
    return -1;
80105a85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8a:	e9 e8 00 00 00       	jmp    80105b77 <sys_link+0x180>
  }

  ip->nlink++;
80105a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a92:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a96:	8d 50 01             	lea    0x1(%eax),%edx
80105a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa3:	89 04 24             	mov    %eax,(%esp)
80105aa6:	e8 04 bd ff ff       	call   801017af <iupdate>
  iunlock(ip);
80105aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aae:	89 04 24             	mov    %eax,(%esp)
80105ab1:	e8 0f c0 ff ff       	call   80101ac5 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105ab6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105ab9:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105abc:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ac0:	89 04 24             	mov    %eax,(%esp)
80105ac3:	e8 7c ca ff ff       	call   80102544 <nameiparent>
80105ac8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105acb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105acf:	75 02                	jne    80105ad3 <sys_link+0xdc>
    goto bad;
80105ad1:	eb 68                	jmp    80105b3b <sys_link+0x144>
  ilock(dp);
80105ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad6:	89 04 24             	mov    %eax,(%esp)
80105ad9:	e8 93 be ff ff       	call   80101971 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae1:	8b 10                	mov    (%eax),%edx
80105ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae6:	8b 00                	mov    (%eax),%eax
80105ae8:	39 c2                	cmp    %eax,%edx
80105aea:	75 20                	jne    80105b0c <sys_link+0x115>
80105aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aef:	8b 40 04             	mov    0x4(%eax),%eax
80105af2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105af6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105af9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b00:	89 04 24             	mov    %eax,(%esp)
80105b03:	e8 5a c7 ff ff       	call   80102262 <dirlink>
80105b08:	85 c0                	test   %eax,%eax
80105b0a:	79 0d                	jns    80105b19 <sys_link+0x122>
    iunlockput(dp);
80105b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0f:	89 04 24             	mov    %eax,(%esp)
80105b12:	e8 e4 c0 ff ff       	call   80101bfb <iunlockput>
    goto bad;
80105b17:	eb 22                	jmp    80105b3b <sys_link+0x144>
  }
  iunlockput(dp);
80105b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1c:	89 04 24             	mov    %eax,(%esp)
80105b1f:	e8 d7 c0 ff ff       	call   80101bfb <iunlockput>
  iput(ip);
80105b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b27:	89 04 24             	mov    %eax,(%esp)
80105b2a:	e8 fb bf ff ff       	call   80101b2a <iput>

  end_op();
80105b2f:	e8 01 db ff ff       	call   80103635 <end_op>

  return 0;
80105b34:	b8 00 00 00 00       	mov    $0x0,%eax
80105b39:	eb 3c                	jmp    80105b77 <sys_link+0x180>

bad:
  ilock(ip);
80105b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3e:	89 04 24             	mov    %eax,(%esp)
80105b41:	e8 2b be ff ff       	call   80101971 <ilock>
  ip->nlink--;
80105b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b49:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b4d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b53:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5a:	89 04 24             	mov    %eax,(%esp)
80105b5d:	e8 4d bc ff ff       	call   801017af <iupdate>
  iunlockput(ip);
80105b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b65:	89 04 24             	mov    %eax,(%esp)
80105b68:	e8 8e c0 ff ff       	call   80101bfb <iunlockput>
  end_op();
80105b6d:	e8 c3 da ff ff       	call   80103635 <end_op>
  return -1;
80105b72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b77:	c9                   	leave  
80105b78:	c3                   	ret    

80105b79 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b79:	55                   	push   %ebp
80105b7a:	89 e5                	mov    %esp,%ebp
80105b7c:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b7f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b86:	eb 4b                	jmp    80105bd3 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b92:	00 
80105b93:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b97:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80105ba1:	89 04 24             	mov    %eax,(%esp)
80105ba4:	e8 db c2 ff ff       	call   80101e84 <readi>
80105ba9:	83 f8 10             	cmp    $0x10,%eax
80105bac:	74 0c                	je     80105bba <isdirempty+0x41>
      panic("isdirempty: readi");
80105bae:	c7 04 24 3e 8d 10 80 	movl   $0x80108d3e,(%esp)
80105bb5:	e8 1d aa ff ff       	call   801005d7 <panic>
    if(de.inum != 0)
80105bba:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105bbe:	66 85 c0             	test   %ax,%ax
80105bc1:	74 07                	je     80105bca <isdirempty+0x51>
      return 0;
80105bc3:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc8:	eb 1b                	jmp    80105be5 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcd:	83 c0 10             	add    $0x10,%eax
80105bd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd9:	8b 40 18             	mov    0x18(%eax),%eax
80105bdc:	39 c2                	cmp    %eax,%edx
80105bde:	72 a8                	jb     80105b88 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105be0:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105be5:	c9                   	leave  
80105be6:	c3                   	ret    

80105be7 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105be7:	55                   	push   %ebp
80105be8:	89 e5                	mov    %esp,%ebp
80105bea:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bed:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bfb:	e8 71 fa ff ff       	call   80105671 <argstr>
80105c00:	85 c0                	test   %eax,%eax
80105c02:	79 0a                	jns    80105c0e <sys_unlink+0x27>
    return -1;
80105c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c09:	e9 af 01 00 00       	jmp    80105dbd <sys_unlink+0x1d6>

  begin_op();
80105c0e:	e8 9e d9 ff ff       	call   801035b1 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c13:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c16:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c19:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c1d:	89 04 24             	mov    %eax,(%esp)
80105c20:	e8 1f c9 ff ff       	call   80102544 <nameiparent>
80105c25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c2c:	75 0f                	jne    80105c3d <sys_unlink+0x56>
    end_op();
80105c2e:	e8 02 da ff ff       	call   80103635 <end_op>
    return -1;
80105c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c38:	e9 80 01 00 00       	jmp    80105dbd <sys_unlink+0x1d6>
  }

  ilock(dp);
80105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c40:	89 04 24             	mov    %eax,(%esp)
80105c43:	e8 29 bd ff ff       	call   80101971 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c48:	c7 44 24 04 50 8d 10 	movl   $0x80108d50,0x4(%esp)
80105c4f:	80 
80105c50:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c53:	89 04 24             	mov    %eax,(%esp)
80105c56:	e8 1c c5 ff ff       	call   80102177 <namecmp>
80105c5b:	85 c0                	test   %eax,%eax
80105c5d:	0f 84 45 01 00 00    	je     80105da8 <sys_unlink+0x1c1>
80105c63:	c7 44 24 04 52 8d 10 	movl   $0x80108d52,0x4(%esp)
80105c6a:	80 
80105c6b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c6e:	89 04 24             	mov    %eax,(%esp)
80105c71:	e8 01 c5 ff ff       	call   80102177 <namecmp>
80105c76:	85 c0                	test   %eax,%eax
80105c78:	0f 84 2a 01 00 00    	je     80105da8 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c7e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c81:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c85:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c88:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c8f:	89 04 24             	mov    %eax,(%esp)
80105c92:	e8 02 c5 ff ff       	call   80102199 <dirlookup>
80105c97:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c9e:	75 05                	jne    80105ca5 <sys_unlink+0xbe>
    goto bad;
80105ca0:	e9 03 01 00 00       	jmp    80105da8 <sys_unlink+0x1c1>
  ilock(ip);
80105ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca8:	89 04 24             	mov    %eax,(%esp)
80105cab:	e8 c1 bc ff ff       	call   80101971 <ilock>

  if(ip->nlink < 1)
80105cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cb7:	66 85 c0             	test   %ax,%ax
80105cba:	7f 0c                	jg     80105cc8 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105cbc:	c7 04 24 55 8d 10 80 	movl   $0x80108d55,(%esp)
80105cc3:	e8 0f a9 ff ff       	call   801005d7 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ccb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ccf:	66 83 f8 01          	cmp    $0x1,%ax
80105cd3:	75 1f                	jne    80105cf4 <sys_unlink+0x10d>
80105cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd8:	89 04 24             	mov    %eax,(%esp)
80105cdb:	e8 99 fe ff ff       	call   80105b79 <isdirempty>
80105ce0:	85 c0                	test   %eax,%eax
80105ce2:	75 10                	jne    80105cf4 <sys_unlink+0x10d>
    iunlockput(ip);
80105ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce7:	89 04 24             	mov    %eax,(%esp)
80105cea:	e8 0c bf ff ff       	call   80101bfb <iunlockput>
    goto bad;
80105cef:	e9 b4 00 00 00       	jmp    80105da8 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105cf4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105cfb:	00 
80105cfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d03:	00 
80105d04:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d07:	89 04 24             	mov    %eax,(%esp)
80105d0a:	e8 90 f5 ff ff       	call   8010529f <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d0f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d12:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d19:	00 
80105d1a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d1e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d21:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d28:	89 04 24             	mov    %eax,(%esp)
80105d2b:	e8 b8 c2 ff ff       	call   80101fe8 <writei>
80105d30:	83 f8 10             	cmp    $0x10,%eax
80105d33:	74 0c                	je     80105d41 <sys_unlink+0x15a>
    panic("unlink: writei");
80105d35:	c7 04 24 67 8d 10 80 	movl   $0x80108d67,(%esp)
80105d3c:	e8 96 a8 ff ff       	call   801005d7 <panic>
  if(ip->type == T_DIR){
80105d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d44:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d48:	66 83 f8 01          	cmp    $0x1,%ax
80105d4c:	75 1c                	jne    80105d6a <sys_unlink+0x183>
    dp->nlink--;
80105d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d51:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d55:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5b:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d62:	89 04 24             	mov    %eax,(%esp)
80105d65:	e8 45 ba ff ff       	call   801017af <iupdate>
  }
  iunlockput(dp);
80105d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d6d:	89 04 24             	mov    %eax,(%esp)
80105d70:	e8 86 be ff ff       	call   80101bfb <iunlockput>

  ip->nlink--;
80105d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d78:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d7c:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d82:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d89:	89 04 24             	mov    %eax,(%esp)
80105d8c:	e8 1e ba ff ff       	call   801017af <iupdate>
  iunlockput(ip);
80105d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d94:	89 04 24             	mov    %eax,(%esp)
80105d97:	e8 5f be ff ff       	call   80101bfb <iunlockput>

  end_op();
80105d9c:	e8 94 d8 ff ff       	call   80103635 <end_op>

  return 0;
80105da1:	b8 00 00 00 00       	mov    $0x0,%eax
80105da6:	eb 15                	jmp    80105dbd <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dab:	89 04 24             	mov    %eax,(%esp)
80105dae:	e8 48 be ff ff       	call   80101bfb <iunlockput>
  end_op();
80105db3:	e8 7d d8 ff ff       	call   80103635 <end_op>
  return -1;
80105db8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dbd:	c9                   	leave  
80105dbe:	c3                   	ret    

80105dbf <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dbf:	55                   	push   %ebp
80105dc0:	89 e5                	mov    %esp,%ebp
80105dc2:	83 ec 48             	sub    $0x48,%esp
80105dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105dc8:	8b 55 10             	mov    0x10(%ebp),%edx
80105dcb:	8b 45 14             	mov    0x14(%ebp),%eax
80105dce:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dd2:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dd6:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dda:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de1:	8b 45 08             	mov    0x8(%ebp),%eax
80105de4:	89 04 24             	mov    %eax,(%esp)
80105de7:	e8 58 c7 ff ff       	call   80102544 <nameiparent>
80105dec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105def:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105df3:	75 0a                	jne    80105dff <create+0x40>
    return 0;
80105df5:	b8 00 00 00 00       	mov    $0x0,%eax
80105dfa:	e9 7e 01 00 00       	jmp    80105f7d <create+0x1be>
  ilock(dp);
80105dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e02:	89 04 24             	mov    %eax,(%esp)
80105e05:	e8 67 bb ff ff       	call   80101971 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e0a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e0d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e11:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e14:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1b:	89 04 24             	mov    %eax,(%esp)
80105e1e:	e8 76 c3 ff ff       	call   80102199 <dirlookup>
80105e23:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e2a:	74 47                	je     80105e73 <create+0xb4>
    iunlockput(dp);
80105e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2f:	89 04 24             	mov    %eax,(%esp)
80105e32:	e8 c4 bd ff ff       	call   80101bfb <iunlockput>
    ilock(ip);
80105e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3a:	89 04 24             	mov    %eax,(%esp)
80105e3d:	e8 2f bb ff ff       	call   80101971 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105e42:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e47:	75 15                	jne    80105e5e <create+0x9f>
80105e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e50:	66 83 f8 02          	cmp    $0x2,%ax
80105e54:	75 08                	jne    80105e5e <create+0x9f>
      return ip;
80105e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e59:	e9 1f 01 00 00       	jmp    80105f7d <create+0x1be>
    iunlockput(ip);
80105e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e61:	89 04 24             	mov    %eax,(%esp)
80105e64:	e8 92 bd ff ff       	call   80101bfb <iunlockput>
    return 0;
80105e69:	b8 00 00 00 00       	mov    $0x0,%eax
80105e6e:	e9 0a 01 00 00       	jmp    80105f7d <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e73:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7a:	8b 00                	mov    (%eax),%eax
80105e7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e80:	89 04 24             	mov    %eax,(%esp)
80105e83:	e8 52 b8 ff ff       	call   801016da <ialloc>
80105e88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e8f:	75 0c                	jne    80105e9d <create+0xde>
    panic("create: ialloc");
80105e91:	c7 04 24 76 8d 10 80 	movl   $0x80108d76,(%esp)
80105e98:	e8 3a a7 ff ff       	call   801005d7 <panic>

  ilock(ip);
80105e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea0:	89 04 24             	mov    %eax,(%esp)
80105ea3:	e8 c9 ba ff ff       	call   80101971 <ilock>
  ip->major = major;
80105ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eab:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105eaf:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105eba:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec1:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eca:	89 04 24             	mov    %eax,(%esp)
80105ecd:	e8 dd b8 ff ff       	call   801017af <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105ed2:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ed7:	75 6a                	jne    80105f43 <create+0x184>
    dp->nlink++;  // for ".."
80105ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ee0:	8d 50 01             	lea    0x1(%eax),%edx
80105ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee6:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eed:	89 04 24             	mov    %eax,(%esp)
80105ef0:	e8 ba b8 ff ff       	call   801017af <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef8:	8b 40 04             	mov    0x4(%eax),%eax
80105efb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105eff:	c7 44 24 04 50 8d 10 	movl   $0x80108d50,0x4(%esp)
80105f06:	80 
80105f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0a:	89 04 24             	mov    %eax,(%esp)
80105f0d:	e8 50 c3 ff ff       	call   80102262 <dirlink>
80105f12:	85 c0                	test   %eax,%eax
80105f14:	78 21                	js     80105f37 <create+0x178>
80105f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f19:	8b 40 04             	mov    0x4(%eax),%eax
80105f1c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f20:	c7 44 24 04 52 8d 10 	movl   $0x80108d52,0x4(%esp)
80105f27:	80 
80105f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2b:	89 04 24             	mov    %eax,(%esp)
80105f2e:	e8 2f c3 ff ff       	call   80102262 <dirlink>
80105f33:	85 c0                	test   %eax,%eax
80105f35:	79 0c                	jns    80105f43 <create+0x184>
      panic("create dots");
80105f37:	c7 04 24 85 8d 10 80 	movl   $0x80108d85,(%esp)
80105f3e:	e8 94 a6 ff ff       	call   801005d7 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f46:	8b 40 04             	mov    0x4(%eax),%eax
80105f49:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f4d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f50:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f57:	89 04 24             	mov    %eax,(%esp)
80105f5a:	e8 03 c3 ff ff       	call   80102262 <dirlink>
80105f5f:	85 c0                	test   %eax,%eax
80105f61:	79 0c                	jns    80105f6f <create+0x1b0>
    panic("create: dirlink");
80105f63:	c7 04 24 91 8d 10 80 	movl   $0x80108d91,(%esp)
80105f6a:	e8 68 a6 ff ff       	call   801005d7 <panic>

  iunlockput(dp);
80105f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f72:	89 04 24             	mov    %eax,(%esp)
80105f75:	e8 81 bc ff ff       	call   80101bfb <iunlockput>

  return ip;
80105f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f7d:	c9                   	leave  
80105f7e:	c3                   	ret    

80105f7f <sys_open>:

int
sys_open(void)
{
80105f7f:	55                   	push   %ebp
80105f80:	89 e5                	mov    %esp,%ebp
80105f82:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f85:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f88:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f93:	e8 d9 f6 ff ff       	call   80105671 <argstr>
80105f98:	85 c0                	test   %eax,%eax
80105f9a:	78 17                	js     80105fb3 <sys_open+0x34>
80105f9c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fa3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105faa:	e8 32 f6 ff ff       	call   801055e1 <argint>
80105faf:	85 c0                	test   %eax,%eax
80105fb1:	79 0a                	jns    80105fbd <sys_open+0x3e>
    return -1;
80105fb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb8:	e9 5c 01 00 00       	jmp    80106119 <sys_open+0x19a>

  begin_op();
80105fbd:	e8 ef d5 ff ff       	call   801035b1 <begin_op>

  if(omode & O_CREATE){
80105fc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fc5:	25 00 02 00 00       	and    $0x200,%eax
80105fca:	85 c0                	test   %eax,%eax
80105fcc:	74 3b                	je     80106009 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105fce:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fd1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105fd8:	00 
80105fd9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fe0:	00 
80105fe1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105fe8:	00 
80105fe9:	89 04 24             	mov    %eax,(%esp)
80105fec:	e8 ce fd ff ff       	call   80105dbf <create>
80105ff1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ff4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ff8:	75 6b                	jne    80106065 <sys_open+0xe6>
      end_op();
80105ffa:	e8 36 d6 ff ff       	call   80103635 <end_op>
      return -1;
80105fff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106004:	e9 10 01 00 00       	jmp    80106119 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106009:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010600c:	89 04 24             	mov    %eax,(%esp)
8010600f:	e8 0e c5 ff ff       	call   80102522 <namei>
80106014:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106017:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010601b:	75 0f                	jne    8010602c <sys_open+0xad>
      end_op();
8010601d:	e8 13 d6 ff ff       	call   80103635 <end_op>
      return -1;
80106022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106027:	e9 ed 00 00 00       	jmp    80106119 <sys_open+0x19a>
    }
    ilock(ip);
8010602c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602f:	89 04 24             	mov    %eax,(%esp)
80106032:	e8 3a b9 ff ff       	call   80101971 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010603e:	66 83 f8 01          	cmp    $0x1,%ax
80106042:	75 21                	jne    80106065 <sys_open+0xe6>
80106044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106047:	85 c0                	test   %eax,%eax
80106049:	74 1a                	je     80106065 <sys_open+0xe6>
      iunlockput(ip);
8010604b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604e:	89 04 24             	mov    %eax,(%esp)
80106051:	e8 a5 bb ff ff       	call   80101bfb <iunlockput>
      end_op();
80106056:	e8 da d5 ff ff       	call   80103635 <end_op>
      return -1;
8010605b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106060:	e9 b4 00 00 00       	jmp    80106119 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106065:	e8 74 af ff ff       	call   80100fde <filealloc>
8010606a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010606d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106071:	74 14                	je     80106087 <sys_open+0x108>
80106073:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106076:	89 04 24             	mov    %eax,(%esp)
80106079:	e8 2e f7 ff ff       	call   801057ac <fdalloc>
8010607e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106081:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106085:	79 28                	jns    801060af <sys_open+0x130>
    if(f)
80106087:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010608b:	74 0b                	je     80106098 <sys_open+0x119>
      fileclose(f);
8010608d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106090:	89 04 24             	mov    %eax,(%esp)
80106093:	e8 ee af ff ff       	call   80101086 <fileclose>
    iunlockput(ip);
80106098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609b:	89 04 24             	mov    %eax,(%esp)
8010609e:	e8 58 bb ff ff       	call   80101bfb <iunlockput>
    end_op();
801060a3:	e8 8d d5 ff ff       	call   80103635 <end_op>
    return -1;
801060a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ad:	eb 6a                	jmp    80106119 <sys_open+0x19a>
  }
  iunlock(ip);
801060af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b2:	89 04 24             	mov    %eax,(%esp)
801060b5:	e8 0b ba ff ff       	call   80101ac5 <iunlock>
  end_op();
801060ba:	e8 76 d5 ff ff       	call   80103635 <end_op>

  f->type = FD_INODE;
801060bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c2:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060ce:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060de:	83 e0 01             	and    $0x1,%eax
801060e1:	85 c0                	test   %eax,%eax
801060e3:	0f 94 c0             	sete   %al
801060e6:	89 c2                	mov    %eax,%edx
801060e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060eb:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f1:	83 e0 01             	and    $0x1,%eax
801060f4:	85 c0                	test   %eax,%eax
801060f6:	75 0a                	jne    80106102 <sys_open+0x183>
801060f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060fb:	83 e0 02             	and    $0x2,%eax
801060fe:	85 c0                	test   %eax,%eax
80106100:	74 07                	je     80106109 <sys_open+0x18a>
80106102:	b8 01 00 00 00       	mov    $0x1,%eax
80106107:	eb 05                	jmp    8010610e <sys_open+0x18f>
80106109:	b8 00 00 00 00       	mov    $0x0,%eax
8010610e:	89 c2                	mov    %eax,%edx
80106110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106113:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106116:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106119:	c9                   	leave  
8010611a:	c3                   	ret    

8010611b <sys_mkdir>:

int
sys_mkdir(void)
{
8010611b:	55                   	push   %ebp
8010611c:	89 e5                	mov    %esp,%ebp
8010611e:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106121:	e8 8b d4 ff ff       	call   801035b1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106126:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106129:	89 44 24 04          	mov    %eax,0x4(%esp)
8010612d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106134:	e8 38 f5 ff ff       	call   80105671 <argstr>
80106139:	85 c0                	test   %eax,%eax
8010613b:	78 2c                	js     80106169 <sys_mkdir+0x4e>
8010613d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106140:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106147:	00 
80106148:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010614f:	00 
80106150:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106157:	00 
80106158:	89 04 24             	mov    %eax,(%esp)
8010615b:	e8 5f fc ff ff       	call   80105dbf <create>
80106160:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106163:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106167:	75 0c                	jne    80106175 <sys_mkdir+0x5a>
    end_op();
80106169:	e8 c7 d4 ff ff       	call   80103635 <end_op>
    return -1;
8010616e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106173:	eb 15                	jmp    8010618a <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106178:	89 04 24             	mov    %eax,(%esp)
8010617b:	e8 7b ba ff ff       	call   80101bfb <iunlockput>
  end_op();
80106180:	e8 b0 d4 ff ff       	call   80103635 <end_op>
  return 0;
80106185:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618a:	c9                   	leave  
8010618b:	c3                   	ret    

8010618c <sys_mknod>:

int
sys_mknod(void)
{
8010618c:	55                   	push   %ebp
8010618d:	89 e5                	mov    %esp,%ebp
8010618f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106192:	e8 1a d4 ff ff       	call   801035b1 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106197:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010619a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010619e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061a5:	e8 c7 f4 ff ff       	call   80105671 <argstr>
801061aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061b1:	78 5e                	js     80106211 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
801061b3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801061c1:	e8 1b f4 ff ff       	call   801055e1 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801061c6:	85 c0                	test   %eax,%eax
801061c8:	78 47                	js     80106211 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801061d1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801061d8:	e8 04 f4 ff ff       	call   801055e1 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061dd:	85 c0                	test   %eax,%eax
801061df:	78 30                	js     80106211 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e4:	0f bf c8             	movswl %ax,%ecx
801061e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061ea:	0f bf d0             	movswl %ax,%edx
801061ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061f0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801061f4:	89 54 24 08          	mov    %edx,0x8(%esp)
801061f8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801061ff:	00 
80106200:	89 04 24             	mov    %eax,(%esp)
80106203:	e8 b7 fb ff ff       	call   80105dbf <create>
80106208:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010620b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010620f:	75 0c                	jne    8010621d <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106211:	e8 1f d4 ff ff       	call   80103635 <end_op>
    return -1;
80106216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621b:	eb 15                	jmp    80106232 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010621d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106220:	89 04 24             	mov    %eax,(%esp)
80106223:	e8 d3 b9 ff ff       	call   80101bfb <iunlockput>
  end_op();
80106228:	e8 08 d4 ff ff       	call   80103635 <end_op>
  return 0;
8010622d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106232:	c9                   	leave  
80106233:	c3                   	ret    

80106234 <sys_chdir>:

int
sys_chdir(void)
{
80106234:	55                   	push   %ebp
80106235:	89 e5                	mov    %esp,%ebp
80106237:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010623a:	e8 72 d3 ff ff       	call   801035b1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010623f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106242:	89 44 24 04          	mov    %eax,0x4(%esp)
80106246:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010624d:	e8 1f f4 ff ff       	call   80105671 <argstr>
80106252:	85 c0                	test   %eax,%eax
80106254:	78 14                	js     8010626a <sys_chdir+0x36>
80106256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106259:	89 04 24             	mov    %eax,(%esp)
8010625c:	e8 c1 c2 ff ff       	call   80102522 <namei>
80106261:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106264:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106268:	75 0c                	jne    80106276 <sys_chdir+0x42>
    end_op();
8010626a:	e8 c6 d3 ff ff       	call   80103635 <end_op>
    return -1;
8010626f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106274:	eb 61                	jmp    801062d7 <sys_chdir+0xa3>
  }
  ilock(ip);
80106276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106279:	89 04 24             	mov    %eax,(%esp)
8010627c:	e8 f0 b6 ff ff       	call   80101971 <ilock>
  if(ip->type != T_DIR){
80106281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106284:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106288:	66 83 f8 01          	cmp    $0x1,%ax
8010628c:	74 17                	je     801062a5 <sys_chdir+0x71>
    iunlockput(ip);
8010628e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106291:	89 04 24             	mov    %eax,(%esp)
80106294:	e8 62 b9 ff ff       	call   80101bfb <iunlockput>
    end_op();
80106299:	e8 97 d3 ff ff       	call   80103635 <end_op>
    return -1;
8010629e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a3:	eb 32                	jmp    801062d7 <sys_chdir+0xa3>
  }
  iunlock(ip);
801062a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a8:	89 04 24             	mov    %eax,(%esp)
801062ab:	e8 15 b8 ff ff       	call   80101ac5 <iunlock>
  iput(proc->cwd);
801062b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b6:	8b 40 68             	mov    0x68(%eax),%eax
801062b9:	89 04 24             	mov    %eax,(%esp)
801062bc:	e8 69 b8 ff ff       	call   80101b2a <iput>
  end_op();
801062c1:	e8 6f d3 ff ff       	call   80103635 <end_op>
  proc->cwd = ip;
801062c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062cf:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062d7:	c9                   	leave  
801062d8:	c3                   	ret    

801062d9 <sys_exec>:

int
sys_exec(void)
{
801062d9:	55                   	push   %ebp
801062da:	89 e5                	mov    %esp,%ebp
801062dc:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801062e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062f0:	e8 7c f3 ff ff       	call   80105671 <argstr>
801062f5:	85 c0                	test   %eax,%eax
801062f7:	78 1a                	js     80106313 <sys_exec+0x3a>
801062f9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80106303:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010630a:	e8 d2 f2 ff ff       	call   801055e1 <argint>
8010630f:	85 c0                	test   %eax,%eax
80106311:	79 0a                	jns    8010631d <sys_exec+0x44>
    return -1;
80106313:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106318:	e9 c8 00 00 00       	jmp    801063e5 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
8010631d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106324:	00 
80106325:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010632c:	00 
8010632d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106333:	89 04 24             	mov    %eax,(%esp)
80106336:	e8 64 ef ff ff       	call   8010529f <memset>
  for(i=0;; i++){
8010633b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106345:	83 f8 1f             	cmp    $0x1f,%eax
80106348:	76 0a                	jbe    80106354 <sys_exec+0x7b>
      return -1;
8010634a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634f:	e9 91 00 00 00       	jmp    801063e5 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106357:	c1 e0 02             	shl    $0x2,%eax
8010635a:	89 c2                	mov    %eax,%edx
8010635c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106362:	01 c2                	add    %eax,%edx
80106364:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010636a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010636e:	89 14 24             	mov    %edx,(%esp)
80106371:	e8 cf f1 ff ff       	call   80105545 <fetchint>
80106376:	85 c0                	test   %eax,%eax
80106378:	79 07                	jns    80106381 <sys_exec+0xa8>
      return -1;
8010637a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637f:	eb 64                	jmp    801063e5 <sys_exec+0x10c>
    if(uarg == 0){
80106381:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106387:	85 c0                	test   %eax,%eax
80106389:	75 26                	jne    801063b1 <sys_exec+0xd8>
      argv[i] = 0;
8010638b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106395:	00 00 00 00 
      break;
80106399:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010639a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639d:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801063a7:	89 04 24             	mov    %eax,(%esp)
801063aa:	e8 f8 a7 ff ff       	call   80100ba7 <exec>
801063af:	eb 34                	jmp    801063e5 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801063b1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063ba:	c1 e2 02             	shl    $0x2,%edx
801063bd:	01 c2                	add    %eax,%edx
801063bf:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801063c9:	89 04 24             	mov    %eax,(%esp)
801063cc:	e8 ae f1 ff ff       	call   8010557f <fetchstr>
801063d1:	85 c0                	test   %eax,%eax
801063d3:	79 07                	jns    801063dc <sys_exec+0x103>
      return -1;
801063d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063da:	eb 09                	jmp    801063e5 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801063dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801063e0:	e9 5d ff ff ff       	jmp    80106342 <sys_exec+0x69>
  return exec(path, argv);
}
801063e5:	c9                   	leave  
801063e6:	c3                   	ret    

801063e7 <sys_pipe>:

int
sys_pipe(void)
{
801063e7:	55                   	push   %ebp
801063e8:	89 e5                	mov    %esp,%ebp
801063ea:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063ed:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801063f4:	00 
801063f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801063fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106403:	e8 07 f2 ff ff       	call   8010560f <argptr>
80106408:	85 c0                	test   %eax,%eax
8010640a:	79 0a                	jns    80106416 <sys_pipe+0x2f>
    return -1;
8010640c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106411:	e9 9b 00 00 00       	jmp    801064b1 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106416:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106419:	89 44 24 04          	mov    %eax,0x4(%esp)
8010641d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106420:	89 04 24             	mov    %eax,(%esp)
80106423:	e8 95 dc ff ff       	call   801040bd <pipealloc>
80106428:	85 c0                	test   %eax,%eax
8010642a:	79 07                	jns    80106433 <sys_pipe+0x4c>
    return -1;
8010642c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106431:	eb 7e                	jmp    801064b1 <sys_pipe+0xca>
  fd0 = -1;
80106433:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010643a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010643d:	89 04 24             	mov    %eax,(%esp)
80106440:	e8 67 f3 ff ff       	call   801057ac <fdalloc>
80106445:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106448:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010644c:	78 14                	js     80106462 <sys_pipe+0x7b>
8010644e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106451:	89 04 24             	mov    %eax,(%esp)
80106454:	e8 53 f3 ff ff       	call   801057ac <fdalloc>
80106459:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010645c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106460:	79 37                	jns    80106499 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106462:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106466:	78 14                	js     8010647c <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106468:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010646e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106471:	83 c2 08             	add    $0x8,%edx
80106474:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010647b:	00 
    fileclose(rf);
8010647c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010647f:	89 04 24             	mov    %eax,(%esp)
80106482:	e8 ff ab ff ff       	call   80101086 <fileclose>
    fileclose(wf);
80106487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010648a:	89 04 24             	mov    %eax,(%esp)
8010648d:	e8 f4 ab ff ff       	call   80101086 <fileclose>
    return -1;
80106492:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106497:	eb 18                	jmp    801064b1 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106499:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010649c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010649f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801064a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064a4:	8d 50 04             	lea    0x4(%eax),%edx
801064a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064aa:	89 02                	mov    %eax,(%edx)
  return 0;
801064ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064b1:	c9                   	leave  
801064b2:	c3                   	ret    

801064b3 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801064b3:	55                   	push   %ebp
801064b4:	89 e5                	mov    %esp,%ebp
801064b6:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064b9:	e8 c7 e2 ff ff       	call   80104785 <fork>
}
801064be:	c9                   	leave  
801064bf:	c3                   	ret    

801064c0 <sys_exit>:

int
sys_exit(void)
{
801064c0:	55                   	push   %ebp
801064c1:	89 e5                	mov    %esp,%ebp
801064c3:	83 ec 08             	sub    $0x8,%esp
  exit();
801064c6:	e8 35 e4 ff ff       	call   80104900 <exit>
  return 0;  // not reached
801064cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064d0:	c9                   	leave  
801064d1:	c3                   	ret    

801064d2 <sys_wait>:

int
sys_wait(void)
{
801064d2:	55                   	push   %ebp
801064d3:	89 e5                	mov    %esp,%ebp
801064d5:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064d8:	e8 45 e5 ff ff       	call   80104a22 <wait>
}
801064dd:	c9                   	leave  
801064de:	c3                   	ret    

801064df <sys_kill>:

int
sys_kill(void)
{
801064df:	55                   	push   %ebp
801064e0:	89 e5                	mov    %esp,%ebp
801064e2:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f3:	e8 e9 f0 ff ff       	call   801055e1 <argint>
801064f8:	85 c0                	test   %eax,%eax
801064fa:	79 07                	jns    80106503 <sys_kill+0x24>
    return -1;
801064fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106501:	eb 0b                	jmp    8010650e <sys_kill+0x2f>
  return kill(pid);
80106503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106506:	89 04 24             	mov    %eax,(%esp)
80106509:	e8 6d e9 ff ff       	call   80104e7b <kill>
}
8010650e:	c9                   	leave  
8010650f:	c3                   	ret    

80106510 <sys_getpid>:

int
sys_getpid(void)
{
80106510:	55                   	push   %ebp
80106511:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106513:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106519:	8b 40 10             	mov    0x10(%eax),%eax
}
8010651c:	5d                   	pop    %ebp
8010651d:	c3                   	ret    

8010651e <sys_sbrk>:

int
sys_sbrk(void)
{
8010651e:	55                   	push   %ebp
8010651f:	89 e5                	mov    %esp,%ebp
80106521:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106524:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106527:	89 44 24 04          	mov    %eax,0x4(%esp)
8010652b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106532:	e8 aa f0 ff ff       	call   801055e1 <argint>
80106537:	85 c0                	test   %eax,%eax
80106539:	79 07                	jns    80106542 <sys_sbrk+0x24>
    return -1;
8010653b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106540:	eb 24                	jmp    80106566 <sys_sbrk+0x48>
  addr = proc->sz;
80106542:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106548:	8b 00                	mov    (%eax),%eax
8010654a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010654d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106550:	89 04 24             	mov    %eax,(%esp)
80106553:	e8 88 e1 ff ff       	call   801046e0 <growproc>
80106558:	85 c0                	test   %eax,%eax
8010655a:	79 07                	jns    80106563 <sys_sbrk+0x45>
    return -1;
8010655c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106561:	eb 03                	jmp    80106566 <sys_sbrk+0x48>
  return addr;
80106563:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106566:	c9                   	leave  
80106567:	c3                   	ret    

80106568 <sys_sleep>:

int
sys_sleep(void)
{
80106568:	55                   	push   %ebp
80106569:	89 e5                	mov    %esp,%ebp
8010656b:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010656e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106571:	89 44 24 04          	mov    %eax,0x4(%esp)
80106575:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010657c:	e8 60 f0 ff ff       	call   801055e1 <argint>
80106581:	85 c0                	test   %eax,%eax
80106583:	79 07                	jns    8010658c <sys_sleep+0x24>
    return -1;
80106585:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658a:	eb 6c                	jmp    801065f8 <sys_sleep+0x90>
  acquire(&tickslock);
8010658c:	c7 04 24 80 53 11 80 	movl   $0x80115380,(%esp)
80106593:	e8 b3 ea ff ff       	call   8010504b <acquire>
  ticks0 = ticks;
80106598:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
8010659d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065a0:	eb 34                	jmp    801065d6 <sys_sleep+0x6e>
    if(proc->killed){
801065a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065a8:	8b 40 24             	mov    0x24(%eax),%eax
801065ab:	85 c0                	test   %eax,%eax
801065ad:	74 13                	je     801065c2 <sys_sleep+0x5a>
      release(&tickslock);
801065af:	c7 04 24 80 53 11 80 	movl   $0x80115380,(%esp)
801065b6:	e8 f2 ea ff ff       	call   801050ad <release>
      return -1;
801065bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c0:	eb 36                	jmp    801065f8 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801065c2:	c7 44 24 04 80 53 11 	movl   $0x80115380,0x4(%esp)
801065c9:	80 
801065ca:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801065d1:	e8 a1 e7 ff ff       	call   80104d77 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801065d6:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
801065db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801065de:	89 c2                	mov    %eax,%edx
801065e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e3:	39 c2                	cmp    %eax,%edx
801065e5:	72 bb                	jb     801065a2 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801065e7:	c7 04 24 80 53 11 80 	movl   $0x80115380,(%esp)
801065ee:	e8 ba ea ff ff       	call   801050ad <release>
  return 0;
801065f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065f8:	c9                   	leave  
801065f9:	c3                   	ret    

801065fa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801065fa:	55                   	push   %ebp
801065fb:	89 e5                	mov    %esp,%ebp
801065fd:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106600:	c7 04 24 80 53 11 80 	movl   $0x80115380,(%esp)
80106607:	e8 3f ea ff ff       	call   8010504b <acquire>
  xticks = ticks;
8010660c:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
80106611:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106614:	c7 04 24 80 53 11 80 	movl   $0x80115380,(%esp)
8010661b:	e8 8d ea ff ff       	call   801050ad <release>
  return xticks;
80106620:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106623:	c9                   	leave  
80106624:	c3                   	ret    

80106625 <sys_gettime>:

int
sys_gettime(void) {
80106625:	55                   	push   %ebp
80106626:	89 e5                	mov    %esp,%ebp
80106628:	83 ec 28             	sub    $0x28,%esp
  struct rtcdate *d;
  if (argptr(0, (char **)&d, sizeof(struct rtcdate)) < 0)
8010662b:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80106632:	00 
80106633:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106636:	89 44 24 04          	mov    %eax,0x4(%esp)
8010663a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106641:	e8 c9 ef ff ff       	call   8010560f <argptr>
80106646:	85 c0                	test   %eax,%eax
80106648:	79 07                	jns    80106651 <sys_gettime+0x2c>
      return -1;
8010664a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664f:	eb 10                	jmp    80106661 <sys_gettime+0x3c>
  cmostime(d);
80106651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106654:	89 04 24             	mov    %eax,(%esp)
80106657:	e8 97 cb ff ff       	call   801031f3 <cmostime>
  return 0;
8010665c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106661:	c9                   	leave  
80106662:	c3                   	ret    

80106663 <sys_settickets>:

// Set number of tickets for a process
int
sys_settickets(void) {
80106663:	55                   	push   %ebp
80106664:	89 e5                	mov    %esp,%ebp
80106666:	83 ec 28             	sub    $0x28,%esp
  int num_tickets;

  if (argint(0, &num_tickets) < 0)
80106669:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010666c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106670:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106677:	e8 65 ef ff ff       	call   801055e1 <argint>
8010667c:	85 c0                	test   %eax,%eax
8010667e:	79 0f                	jns    8010668f <sys_settickets+0x2c>
		// set to default value
    proc->tickets = 20;
80106680:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106686:	c7 40 7c 14 00 00 00 	movl   $0x14,0x7c(%eax)
8010668d:	eb 0c                	jmp    8010669b <sys_settickets+0x38>
  else
    proc->tickets = num_tickets;
8010668f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106695:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106698:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
8010669b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066a0:	c9                   	leave  
801066a1:	c3                   	ret    

801066a2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801066a2:	55                   	push   %ebp
801066a3:	89 e5                	mov    %esp,%ebp
801066a5:	83 ec 08             	sub    $0x8,%esp
801066a8:	8b 55 08             	mov    0x8(%ebp),%edx
801066ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801066ae:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801066b2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066b5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066b9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066bd:	ee                   	out    %al,(%dx)
}
801066be:	c9                   	leave  
801066bf:	c3                   	ret    

801066c0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801066c0:	55                   	push   %ebp
801066c1:	89 e5                	mov    %esp,%ebp
801066c3:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801066c6:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801066cd:	00 
801066ce:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801066d5:	e8 c8 ff ff ff       	call   801066a2 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801066da:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801066e1:	00 
801066e2:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801066e9:	e8 b4 ff ff ff       	call   801066a2 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801066ee:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801066f5:	00 
801066f6:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801066fd:	e8 a0 ff ff ff       	call   801066a2 <outb>
  picenable(IRQ_TIMER);
80106702:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106709:	e8 42 d8 ff ff       	call   80103f50 <picenable>
}
8010670e:	c9                   	leave  
8010670f:	c3                   	ret    

80106710 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106710:	1e                   	push   %ds
  pushl %es
80106711:	06                   	push   %es
  pushl %fs
80106712:	0f a0                	push   %fs
  pushl %gs
80106714:	0f a8                	push   %gs
  pushal
80106716:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106717:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010671b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010671d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010671f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106723:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106725:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106727:	54                   	push   %esp
  call trap
80106728:	e8 d8 01 00 00       	call   80106905 <trap>
  addl $4, %esp
8010672d:	83 c4 04             	add    $0x4,%esp

80106730 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106730:	61                   	popa   
  popl %gs
80106731:	0f a9                	pop    %gs
  popl %fs
80106733:	0f a1                	pop    %fs
  popl %es
80106735:	07                   	pop    %es
  popl %ds
80106736:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106737:	83 c4 08             	add    $0x8,%esp
  iret
8010673a:	cf                   	iret   

8010673b <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010673b:	55                   	push   %ebp
8010673c:	89 e5                	mov    %esp,%ebp
8010673e:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106741:	8b 45 0c             	mov    0xc(%ebp),%eax
80106744:	83 e8 01             	sub    $0x1,%eax
80106747:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010674b:	8b 45 08             	mov    0x8(%ebp),%eax
8010674e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106752:	8b 45 08             	mov    0x8(%ebp),%eax
80106755:	c1 e8 10             	shr    $0x10,%eax
80106758:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010675c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010675f:	0f 01 18             	lidtl  (%eax)
}
80106762:	c9                   	leave  
80106763:	c3                   	ret    

80106764 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106764:	55                   	push   %ebp
80106765:	89 e5                	mov    %esp,%ebp
80106767:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010676a:	0f 20 d0             	mov    %cr2,%eax
8010676d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106770:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106773:	c9                   	leave  
80106774:	c3                   	ret    

80106775 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106775:	55                   	push   %ebp
80106776:	89 e5                	mov    %esp,%ebp
80106778:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010677b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106782:	e9 c3 00 00 00       	jmp    8010684a <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010678a:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106791:	89 c2                	mov    %eax,%edx
80106793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106796:	66 89 14 c5 c0 53 11 	mov    %dx,-0x7feeac40(,%eax,8)
8010679d:	80 
8010679e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a1:	66 c7 04 c5 c2 53 11 	movw   $0x8,-0x7feeac3e(,%eax,8)
801067a8:	80 08 00 
801067ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ae:	0f b6 14 c5 c4 53 11 	movzbl -0x7feeac3c(,%eax,8),%edx
801067b5:	80 
801067b6:	83 e2 e0             	and    $0xffffffe0,%edx
801067b9:	88 14 c5 c4 53 11 80 	mov    %dl,-0x7feeac3c(,%eax,8)
801067c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c3:	0f b6 14 c5 c4 53 11 	movzbl -0x7feeac3c(,%eax,8),%edx
801067ca:	80 
801067cb:	83 e2 1f             	and    $0x1f,%edx
801067ce:	88 14 c5 c4 53 11 80 	mov    %dl,-0x7feeac3c(,%eax,8)
801067d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d8:	0f b6 14 c5 c5 53 11 	movzbl -0x7feeac3b(,%eax,8),%edx
801067df:	80 
801067e0:	83 e2 f0             	and    $0xfffffff0,%edx
801067e3:	83 ca 0e             	or     $0xe,%edx
801067e6:	88 14 c5 c5 53 11 80 	mov    %dl,-0x7feeac3b(,%eax,8)
801067ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f0:	0f b6 14 c5 c5 53 11 	movzbl -0x7feeac3b(,%eax,8),%edx
801067f7:	80 
801067f8:	83 e2 ef             	and    $0xffffffef,%edx
801067fb:	88 14 c5 c5 53 11 80 	mov    %dl,-0x7feeac3b(,%eax,8)
80106802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106805:	0f b6 14 c5 c5 53 11 	movzbl -0x7feeac3b(,%eax,8),%edx
8010680c:	80 
8010680d:	83 e2 9f             	and    $0xffffff9f,%edx
80106810:	88 14 c5 c5 53 11 80 	mov    %dl,-0x7feeac3b(,%eax,8)
80106817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681a:	0f b6 14 c5 c5 53 11 	movzbl -0x7feeac3b(,%eax,8),%edx
80106821:	80 
80106822:	83 ca 80             	or     $0xffffff80,%edx
80106825:	88 14 c5 c5 53 11 80 	mov    %dl,-0x7feeac3b(,%eax,8)
8010682c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682f:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106836:	c1 e8 10             	shr    $0x10,%eax
80106839:	89 c2                	mov    %eax,%edx
8010683b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683e:	66 89 14 c5 c6 53 11 	mov    %dx,-0x7feeac3a(,%eax,8)
80106845:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106846:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010684a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106851:	0f 8e 30 ff ff ff    	jle    80106787 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106857:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
8010685c:	66 a3 c0 55 11 80    	mov    %ax,0x801155c0
80106862:	66 c7 05 c2 55 11 80 	movw   $0x8,0x801155c2
80106869:	08 00 
8010686b:	0f b6 05 c4 55 11 80 	movzbl 0x801155c4,%eax
80106872:	83 e0 e0             	and    $0xffffffe0,%eax
80106875:	a2 c4 55 11 80       	mov    %al,0x801155c4
8010687a:	0f b6 05 c4 55 11 80 	movzbl 0x801155c4,%eax
80106881:	83 e0 1f             	and    $0x1f,%eax
80106884:	a2 c4 55 11 80       	mov    %al,0x801155c4
80106889:	0f b6 05 c5 55 11 80 	movzbl 0x801155c5,%eax
80106890:	83 c8 0f             	or     $0xf,%eax
80106893:	a2 c5 55 11 80       	mov    %al,0x801155c5
80106898:	0f b6 05 c5 55 11 80 	movzbl 0x801155c5,%eax
8010689f:	83 e0 ef             	and    $0xffffffef,%eax
801068a2:	a2 c5 55 11 80       	mov    %al,0x801155c5
801068a7:	0f b6 05 c5 55 11 80 	movzbl 0x801155c5,%eax
801068ae:	83 c8 60             	or     $0x60,%eax
801068b1:	a2 c5 55 11 80       	mov    %al,0x801155c5
801068b6:	0f b6 05 c5 55 11 80 	movzbl 0x801155c5,%eax
801068bd:	83 c8 80             	or     $0xffffff80,%eax
801068c0:	a2 c5 55 11 80       	mov    %al,0x801155c5
801068c5:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801068ca:	c1 e8 10             	shr    $0x10,%eax
801068cd:	66 a3 c6 55 11 80    	mov    %ax,0x801155c6
  
  initlock(&tickslock, "time");
801068d3:	c7 44 24 04 a4 8d 10 	movl   $0x80108da4,0x4(%esp)
801068da:	80 
801068db:	c7 04 24 80 53 11 80 	movl   $0x80115380,(%esp)
801068e2:	e8 43 e7 ff ff       	call   8010502a <initlock>
}
801068e7:	c9                   	leave  
801068e8:	c3                   	ret    

801068e9 <idtinit>:

void
idtinit(void)
{
801068e9:	55                   	push   %ebp
801068ea:	89 e5                	mov    %esp,%ebp
801068ec:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801068ef:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801068f6:	00 
801068f7:	c7 04 24 c0 53 11 80 	movl   $0x801153c0,(%esp)
801068fe:	e8 38 fe ff ff       	call   8010673b <lidt>
}
80106903:	c9                   	leave  
80106904:	c3                   	ret    

80106905 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106905:	55                   	push   %ebp
80106906:	89 e5                	mov    %esp,%ebp
80106908:	57                   	push   %edi
80106909:	56                   	push   %esi
8010690a:	53                   	push   %ebx
8010690b:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010690e:	8b 45 08             	mov    0x8(%ebp),%eax
80106911:	8b 40 30             	mov    0x30(%eax),%eax
80106914:	83 f8 40             	cmp    $0x40,%eax
80106917:	75 3f                	jne    80106958 <trap+0x53>
    if(proc->killed)
80106919:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010691f:	8b 40 24             	mov    0x24(%eax),%eax
80106922:	85 c0                	test   %eax,%eax
80106924:	74 05                	je     8010692b <trap+0x26>
      exit();
80106926:	e8 d5 df ff ff       	call   80104900 <exit>
    proc->tf = tf;
8010692b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106931:	8b 55 08             	mov    0x8(%ebp),%edx
80106934:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106937:	e8 6c ed ff ff       	call   801056a8 <syscall>
    if(proc->killed)
8010693c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106942:	8b 40 24             	mov    0x24(%eax),%eax
80106945:	85 c0                	test   %eax,%eax
80106947:	74 0a                	je     80106953 <trap+0x4e>
      exit();
80106949:	e8 b2 df ff ff       	call   80104900 <exit>
    return;
8010694e:	e9 2d 02 00 00       	jmp    80106b80 <trap+0x27b>
80106953:	e9 28 02 00 00       	jmp    80106b80 <trap+0x27b>
  }

  switch(tf->trapno){
80106958:	8b 45 08             	mov    0x8(%ebp),%eax
8010695b:	8b 40 30             	mov    0x30(%eax),%eax
8010695e:	83 e8 20             	sub    $0x20,%eax
80106961:	83 f8 1f             	cmp    $0x1f,%eax
80106964:	0f 87 bc 00 00 00    	ja     80106a26 <trap+0x121>
8010696a:	8b 04 85 4c 8e 10 80 	mov    -0x7fef71b4(,%eax,4),%eax
80106971:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106973:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106979:	0f b6 00             	movzbl (%eax),%eax
8010697c:	84 c0                	test   %al,%al
8010697e:	75 31                	jne    801069b1 <trap+0xac>
      acquire(&tickslock);
80106980:	c7 04 24 80 53 11 80 	movl   $0x80115380,(%esp)
80106987:	e8 bf e6 ff ff       	call   8010504b <acquire>
      ticks++;
8010698c:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
80106991:	83 c0 01             	add    $0x1,%eax
80106994:	a3 c0 5b 11 80       	mov    %eax,0x80115bc0
      wakeup(&ticks);
80106999:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801069a0:	e8 ab e4 ff ff       	call   80104e50 <wakeup>
      release(&tickslock);
801069a5:	c7 04 24 80 53 11 80 	movl   $0x80115380,(%esp)
801069ac:	e8 fc e6 ff ff       	call   801050ad <release>
    }
    lapiceoi();
801069b1:	e8 6d c6 ff ff       	call   80103023 <lapiceoi>
    break;
801069b6:	e9 41 01 00 00       	jmp    80106afc <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801069bb:	e8 71 be ff ff       	call   80102831 <ideintr>
    lapiceoi();
801069c0:	e8 5e c6 ff ff       	call   80103023 <lapiceoi>
    break;
801069c5:	e9 32 01 00 00       	jmp    80106afc <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801069ca:	e8 23 c4 ff ff       	call   80102df2 <kbdintr>
    lapiceoi();
801069cf:	e8 4f c6 ff ff       	call   80103023 <lapiceoi>
    break;
801069d4:	e9 23 01 00 00       	jmp    80106afc <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801069d9:	e8 97 03 00 00       	call   80106d75 <uartintr>
    lapiceoi();
801069de:	e8 40 c6 ff ff       	call   80103023 <lapiceoi>
    break;
801069e3:	e9 14 01 00 00       	jmp    80106afc <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069e8:	8b 45 08             	mov    0x8(%ebp),%eax
801069eb:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801069ee:	8b 45 08             	mov    0x8(%ebp),%eax
801069f1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069f5:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801069f8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069fe:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a01:	0f b6 c0             	movzbl %al,%eax
80106a04:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a08:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a10:	c7 04 24 ac 8d 10 80 	movl   $0x80108dac,(%esp)
80106a17:	e8 e7 99 ff ff       	call   80100403 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106a1c:	e8 02 c6 ff ff       	call   80103023 <lapiceoi>
    break;
80106a21:	e9 d6 00 00 00       	jmp    80106afc <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a2c:	85 c0                	test   %eax,%eax
80106a2e:	74 11                	je     80106a41 <trap+0x13c>
80106a30:	8b 45 08             	mov    0x8(%ebp),%eax
80106a33:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a37:	0f b7 c0             	movzwl %ax,%eax
80106a3a:	83 e0 03             	and    $0x3,%eax
80106a3d:	85 c0                	test   %eax,%eax
80106a3f:	75 46                	jne    80106a87 <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a41:	e8 1e fd ff ff       	call   80106764 <rcr2>
80106a46:	8b 55 08             	mov    0x8(%ebp),%edx
80106a49:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106a4c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106a53:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a56:	0f b6 ca             	movzbl %dl,%ecx
80106a59:	8b 55 08             	mov    0x8(%ebp),%edx
80106a5c:	8b 52 30             	mov    0x30(%edx),%edx
80106a5f:	89 44 24 10          	mov    %eax,0x10(%esp)
80106a63:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106a67:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106a6b:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a6f:	c7 04 24 d0 8d 10 80 	movl   $0x80108dd0,(%esp)
80106a76:	e8 88 99 ff ff       	call   80100403 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106a7b:	c7 04 24 02 8e 10 80 	movl   $0x80108e02,(%esp)
80106a82:	e8 50 9b ff ff       	call   801005d7 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a87:	e8 d8 fc ff ff       	call   80106764 <rcr2>
80106a8c:	89 c2                	mov    %eax,%edx
80106a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a91:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a94:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a9a:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a9d:	0f b6 f0             	movzbl %al,%esi
80106aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa3:	8b 58 34             	mov    0x34(%eax),%ebx
80106aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa9:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106aac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab2:	83 c0 6c             	add    $0x6c,%eax
80106ab5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106ab8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106abe:	8b 40 10             	mov    0x10(%eax),%eax
80106ac1:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106ac5:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106ac9:	89 74 24 14          	mov    %esi,0x14(%esp)
80106acd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106ad1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ad5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106ad8:	89 74 24 08          	mov    %esi,0x8(%esp)
80106adc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ae0:	c7 04 24 08 8e 10 80 	movl   $0x80108e08,(%esp)
80106ae7:	e8 17 99 ff ff       	call   80100403 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106aec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106af2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106af9:	eb 01                	jmp    80106afc <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106afb:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106afc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b02:	85 c0                	test   %eax,%eax
80106b04:	74 24                	je     80106b2a <trap+0x225>
80106b06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b0c:	8b 40 24             	mov    0x24(%eax),%eax
80106b0f:	85 c0                	test   %eax,%eax
80106b11:	74 17                	je     80106b2a <trap+0x225>
80106b13:	8b 45 08             	mov    0x8(%ebp),%eax
80106b16:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b1a:	0f b7 c0             	movzwl %ax,%eax
80106b1d:	83 e0 03             	and    $0x3,%eax
80106b20:	83 f8 03             	cmp    $0x3,%eax
80106b23:	75 05                	jne    80106b2a <trap+0x225>
    exit();
80106b25:	e8 d6 dd ff ff       	call   80104900 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106b2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b30:	85 c0                	test   %eax,%eax
80106b32:	74 1e                	je     80106b52 <trap+0x24d>
80106b34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b3a:	8b 40 0c             	mov    0xc(%eax),%eax
80106b3d:	83 f8 04             	cmp    $0x4,%eax
80106b40:	75 10                	jne    80106b52 <trap+0x24d>
80106b42:	8b 45 08             	mov    0x8(%ebp),%eax
80106b45:	8b 40 30             	mov    0x30(%eax),%eax
80106b48:	83 f8 20             	cmp    $0x20,%eax
80106b4b:	75 05                	jne    80106b52 <trap+0x24d>
    yield();
80106b4d:	e8 b4 e1 ff ff       	call   80104d06 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b58:	85 c0                	test   %eax,%eax
80106b5a:	74 24                	je     80106b80 <trap+0x27b>
80106b5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b62:	8b 40 24             	mov    0x24(%eax),%eax
80106b65:	85 c0                	test   %eax,%eax
80106b67:	74 17                	je     80106b80 <trap+0x27b>
80106b69:	8b 45 08             	mov    0x8(%ebp),%eax
80106b6c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b70:	0f b7 c0             	movzwl %ax,%eax
80106b73:	83 e0 03             	and    $0x3,%eax
80106b76:	83 f8 03             	cmp    $0x3,%eax
80106b79:	75 05                	jne    80106b80 <trap+0x27b>
    exit();
80106b7b:	e8 80 dd ff ff       	call   80104900 <exit>
}
80106b80:	83 c4 3c             	add    $0x3c,%esp
80106b83:	5b                   	pop    %ebx
80106b84:	5e                   	pop    %esi
80106b85:	5f                   	pop    %edi
80106b86:	5d                   	pop    %ebp
80106b87:	c3                   	ret    

80106b88 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106b88:	55                   	push   %ebp
80106b89:	89 e5                	mov    %esp,%ebp
80106b8b:	83 ec 14             	sub    $0x14,%esp
80106b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80106b91:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b95:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b99:	89 c2                	mov    %eax,%edx
80106b9b:	ec                   	in     (%dx),%al
80106b9c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b9f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106ba3:	c9                   	leave  
80106ba4:	c3                   	ret    

80106ba5 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106ba5:	55                   	push   %ebp
80106ba6:	89 e5                	mov    %esp,%ebp
80106ba8:	83 ec 08             	sub    $0x8,%esp
80106bab:	8b 55 08             	mov    0x8(%ebp),%edx
80106bae:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bb1:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106bb5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106bb8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106bbc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106bc0:	ee                   	out    %al,(%dx)
}
80106bc1:	c9                   	leave  
80106bc2:	c3                   	ret    

80106bc3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106bc3:	55                   	push   %ebp
80106bc4:	89 e5                	mov    %esp,%ebp
80106bc6:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106bc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106bd0:	00 
80106bd1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106bd8:	e8 c8 ff ff ff       	call   80106ba5 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106bdd:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106be4:	00 
80106be5:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106bec:	e8 b4 ff ff ff       	call   80106ba5 <outb>
  outb(COM1+0, 115200/9600);
80106bf1:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106bf8:	00 
80106bf9:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c00:	e8 a0 ff ff ff       	call   80106ba5 <outb>
  outb(COM1+1, 0);
80106c05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c0c:	00 
80106c0d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c14:	e8 8c ff ff ff       	call   80106ba5 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c19:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c20:	00 
80106c21:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c28:	e8 78 ff ff ff       	call   80106ba5 <outb>
  outb(COM1+4, 0);
80106c2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c34:	00 
80106c35:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106c3c:	e8 64 ff ff ff       	call   80106ba5 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106c48:	00 
80106c49:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c50:	e8 50 ff ff ff       	call   80106ba5 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106c55:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c5c:	e8 27 ff ff ff       	call   80106b88 <inb>
80106c61:	3c ff                	cmp    $0xff,%al
80106c63:	75 02                	jne    80106c67 <uartinit+0xa4>
    return;
80106c65:	eb 6a                	jmp    80106cd1 <uartinit+0x10e>
  uart = 1;
80106c67:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
80106c6e:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106c71:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c78:	e8 0b ff ff ff       	call   80106b88 <inb>
  inb(COM1+0);
80106c7d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c84:	e8 ff fe ff ff       	call   80106b88 <inb>
  picenable(IRQ_COM1);
80106c89:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106c90:	e8 bb d2 ff ff       	call   80103f50 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106c95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c9c:	00 
80106c9d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ca4:	e8 07 be ff ff       	call   80102ab0 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ca9:	c7 45 f4 cc 8e 10 80 	movl   $0x80108ecc,-0xc(%ebp)
80106cb0:	eb 15                	jmp    80106cc7 <uartinit+0x104>
    uartputc(*p);
80106cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cb5:	0f b6 00             	movzbl (%eax),%eax
80106cb8:	0f be c0             	movsbl %al,%eax
80106cbb:	89 04 24             	mov    %eax,(%esp)
80106cbe:	e8 10 00 00 00       	call   80106cd3 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106cc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cca:	0f b6 00             	movzbl (%eax),%eax
80106ccd:	84 c0                	test   %al,%al
80106ccf:	75 e1                	jne    80106cb2 <uartinit+0xef>
    uartputc(*p);
}
80106cd1:	c9                   	leave  
80106cd2:	c3                   	ret    

80106cd3 <uartputc>:

void
uartputc(int c)
{
80106cd3:	55                   	push   %ebp
80106cd4:	89 e5                	mov    %esp,%ebp
80106cd6:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106cd9:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106cde:	85 c0                	test   %eax,%eax
80106ce0:	75 02                	jne    80106ce4 <uartputc+0x11>
    return;
80106ce2:	eb 4b                	jmp    80106d2f <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ce4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ceb:	eb 10                	jmp    80106cfd <uartputc+0x2a>
    microdelay(10);
80106ced:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106cf4:	e8 4f c3 ff ff       	call   80103048 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106cf9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106cfd:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d01:	7f 16                	jg     80106d19 <uartputc+0x46>
80106d03:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d0a:	e8 79 fe ff ff       	call   80106b88 <inb>
80106d0f:	0f b6 c0             	movzbl %al,%eax
80106d12:	83 e0 20             	and    $0x20,%eax
80106d15:	85 c0                	test   %eax,%eax
80106d17:	74 d4                	je     80106ced <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106d19:	8b 45 08             	mov    0x8(%ebp),%eax
80106d1c:	0f b6 c0             	movzbl %al,%eax
80106d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d23:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d2a:	e8 76 fe ff ff       	call   80106ba5 <outb>
}
80106d2f:	c9                   	leave  
80106d30:	c3                   	ret    

80106d31 <uartgetc>:

static int
uartgetc(void)
{
80106d31:	55                   	push   %ebp
80106d32:	89 e5                	mov    %esp,%ebp
80106d34:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106d37:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106d3c:	85 c0                	test   %eax,%eax
80106d3e:	75 07                	jne    80106d47 <uartgetc+0x16>
    return -1;
80106d40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d45:	eb 2c                	jmp    80106d73 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106d47:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d4e:	e8 35 fe ff ff       	call   80106b88 <inb>
80106d53:	0f b6 c0             	movzbl %al,%eax
80106d56:	83 e0 01             	and    $0x1,%eax
80106d59:	85 c0                	test   %eax,%eax
80106d5b:	75 07                	jne    80106d64 <uartgetc+0x33>
    return -1;
80106d5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d62:	eb 0f                	jmp    80106d73 <uartgetc+0x42>
  return inb(COM1+0);
80106d64:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d6b:	e8 18 fe ff ff       	call   80106b88 <inb>
80106d70:	0f b6 c0             	movzbl %al,%eax
}
80106d73:	c9                   	leave  
80106d74:	c3                   	ret    

80106d75 <uartintr>:

void
uartintr(void)
{
80106d75:	55                   	push   %ebp
80106d76:	89 e5                	mov    %esp,%ebp
80106d78:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106d7b:	c7 04 24 31 6d 10 80 	movl   $0x80106d31,(%esp)
80106d82:	e8 de 9a ff ff       	call   80100865 <consoleintr>
}
80106d87:	c9                   	leave  
80106d88:	c3                   	ret    

80106d89 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $0
80106d8b:	6a 00                	push   $0x0
  jmp alltraps
80106d8d:	e9 7e f9 ff ff       	jmp    80106710 <alltraps>

80106d92 <vector1>:
.globl vector1
vector1:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $1
80106d94:	6a 01                	push   $0x1
  jmp alltraps
80106d96:	e9 75 f9 ff ff       	jmp    80106710 <alltraps>

80106d9b <vector2>:
.globl vector2
vector2:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $2
80106d9d:	6a 02                	push   $0x2
  jmp alltraps
80106d9f:	e9 6c f9 ff ff       	jmp    80106710 <alltraps>

80106da4 <vector3>:
.globl vector3
vector3:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $3
80106da6:	6a 03                	push   $0x3
  jmp alltraps
80106da8:	e9 63 f9 ff ff       	jmp    80106710 <alltraps>

80106dad <vector4>:
.globl vector4
vector4:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $4
80106daf:	6a 04                	push   $0x4
  jmp alltraps
80106db1:	e9 5a f9 ff ff       	jmp    80106710 <alltraps>

80106db6 <vector5>:
.globl vector5
vector5:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $5
80106db8:	6a 05                	push   $0x5
  jmp alltraps
80106dba:	e9 51 f9 ff ff       	jmp    80106710 <alltraps>

80106dbf <vector6>:
.globl vector6
vector6:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $6
80106dc1:	6a 06                	push   $0x6
  jmp alltraps
80106dc3:	e9 48 f9 ff ff       	jmp    80106710 <alltraps>

80106dc8 <vector7>:
.globl vector7
vector7:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $7
80106dca:	6a 07                	push   $0x7
  jmp alltraps
80106dcc:	e9 3f f9 ff ff       	jmp    80106710 <alltraps>

80106dd1 <vector8>:
.globl vector8
vector8:
  pushl $8
80106dd1:	6a 08                	push   $0x8
  jmp alltraps
80106dd3:	e9 38 f9 ff ff       	jmp    80106710 <alltraps>

80106dd8 <vector9>:
.globl vector9
vector9:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $9
80106dda:	6a 09                	push   $0x9
  jmp alltraps
80106ddc:	e9 2f f9 ff ff       	jmp    80106710 <alltraps>

80106de1 <vector10>:
.globl vector10
vector10:
  pushl $10
80106de1:	6a 0a                	push   $0xa
  jmp alltraps
80106de3:	e9 28 f9 ff ff       	jmp    80106710 <alltraps>

80106de8 <vector11>:
.globl vector11
vector11:
  pushl $11
80106de8:	6a 0b                	push   $0xb
  jmp alltraps
80106dea:	e9 21 f9 ff ff       	jmp    80106710 <alltraps>

80106def <vector12>:
.globl vector12
vector12:
  pushl $12
80106def:	6a 0c                	push   $0xc
  jmp alltraps
80106df1:	e9 1a f9 ff ff       	jmp    80106710 <alltraps>

80106df6 <vector13>:
.globl vector13
vector13:
  pushl $13
80106df6:	6a 0d                	push   $0xd
  jmp alltraps
80106df8:	e9 13 f9 ff ff       	jmp    80106710 <alltraps>

80106dfd <vector14>:
.globl vector14
vector14:
  pushl $14
80106dfd:	6a 0e                	push   $0xe
  jmp alltraps
80106dff:	e9 0c f9 ff ff       	jmp    80106710 <alltraps>

80106e04 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $15
80106e06:	6a 0f                	push   $0xf
  jmp alltraps
80106e08:	e9 03 f9 ff ff       	jmp    80106710 <alltraps>

80106e0d <vector16>:
.globl vector16
vector16:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $16
80106e0f:	6a 10                	push   $0x10
  jmp alltraps
80106e11:	e9 fa f8 ff ff       	jmp    80106710 <alltraps>

80106e16 <vector17>:
.globl vector17
vector17:
  pushl $17
80106e16:	6a 11                	push   $0x11
  jmp alltraps
80106e18:	e9 f3 f8 ff ff       	jmp    80106710 <alltraps>

80106e1d <vector18>:
.globl vector18
vector18:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $18
80106e1f:	6a 12                	push   $0x12
  jmp alltraps
80106e21:	e9 ea f8 ff ff       	jmp    80106710 <alltraps>

80106e26 <vector19>:
.globl vector19
vector19:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $19
80106e28:	6a 13                	push   $0x13
  jmp alltraps
80106e2a:	e9 e1 f8 ff ff       	jmp    80106710 <alltraps>

80106e2f <vector20>:
.globl vector20
vector20:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $20
80106e31:	6a 14                	push   $0x14
  jmp alltraps
80106e33:	e9 d8 f8 ff ff       	jmp    80106710 <alltraps>

80106e38 <vector21>:
.globl vector21
vector21:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $21
80106e3a:	6a 15                	push   $0x15
  jmp alltraps
80106e3c:	e9 cf f8 ff ff       	jmp    80106710 <alltraps>

80106e41 <vector22>:
.globl vector22
vector22:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $22
80106e43:	6a 16                	push   $0x16
  jmp alltraps
80106e45:	e9 c6 f8 ff ff       	jmp    80106710 <alltraps>

80106e4a <vector23>:
.globl vector23
vector23:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $23
80106e4c:	6a 17                	push   $0x17
  jmp alltraps
80106e4e:	e9 bd f8 ff ff       	jmp    80106710 <alltraps>

80106e53 <vector24>:
.globl vector24
vector24:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $24
80106e55:	6a 18                	push   $0x18
  jmp alltraps
80106e57:	e9 b4 f8 ff ff       	jmp    80106710 <alltraps>

80106e5c <vector25>:
.globl vector25
vector25:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $25
80106e5e:	6a 19                	push   $0x19
  jmp alltraps
80106e60:	e9 ab f8 ff ff       	jmp    80106710 <alltraps>

80106e65 <vector26>:
.globl vector26
vector26:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $26
80106e67:	6a 1a                	push   $0x1a
  jmp alltraps
80106e69:	e9 a2 f8 ff ff       	jmp    80106710 <alltraps>

80106e6e <vector27>:
.globl vector27
vector27:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $27
80106e70:	6a 1b                	push   $0x1b
  jmp alltraps
80106e72:	e9 99 f8 ff ff       	jmp    80106710 <alltraps>

80106e77 <vector28>:
.globl vector28
vector28:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $28
80106e79:	6a 1c                	push   $0x1c
  jmp alltraps
80106e7b:	e9 90 f8 ff ff       	jmp    80106710 <alltraps>

80106e80 <vector29>:
.globl vector29
vector29:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $29
80106e82:	6a 1d                	push   $0x1d
  jmp alltraps
80106e84:	e9 87 f8 ff ff       	jmp    80106710 <alltraps>

80106e89 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $30
80106e8b:	6a 1e                	push   $0x1e
  jmp alltraps
80106e8d:	e9 7e f8 ff ff       	jmp    80106710 <alltraps>

80106e92 <vector31>:
.globl vector31
vector31:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $31
80106e94:	6a 1f                	push   $0x1f
  jmp alltraps
80106e96:	e9 75 f8 ff ff       	jmp    80106710 <alltraps>

80106e9b <vector32>:
.globl vector32
vector32:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $32
80106e9d:	6a 20                	push   $0x20
  jmp alltraps
80106e9f:	e9 6c f8 ff ff       	jmp    80106710 <alltraps>

80106ea4 <vector33>:
.globl vector33
vector33:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $33
80106ea6:	6a 21                	push   $0x21
  jmp alltraps
80106ea8:	e9 63 f8 ff ff       	jmp    80106710 <alltraps>

80106ead <vector34>:
.globl vector34
vector34:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $34
80106eaf:	6a 22                	push   $0x22
  jmp alltraps
80106eb1:	e9 5a f8 ff ff       	jmp    80106710 <alltraps>

80106eb6 <vector35>:
.globl vector35
vector35:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $35
80106eb8:	6a 23                	push   $0x23
  jmp alltraps
80106eba:	e9 51 f8 ff ff       	jmp    80106710 <alltraps>

80106ebf <vector36>:
.globl vector36
vector36:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $36
80106ec1:	6a 24                	push   $0x24
  jmp alltraps
80106ec3:	e9 48 f8 ff ff       	jmp    80106710 <alltraps>

80106ec8 <vector37>:
.globl vector37
vector37:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $37
80106eca:	6a 25                	push   $0x25
  jmp alltraps
80106ecc:	e9 3f f8 ff ff       	jmp    80106710 <alltraps>

80106ed1 <vector38>:
.globl vector38
vector38:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $38
80106ed3:	6a 26                	push   $0x26
  jmp alltraps
80106ed5:	e9 36 f8 ff ff       	jmp    80106710 <alltraps>

80106eda <vector39>:
.globl vector39
vector39:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $39
80106edc:	6a 27                	push   $0x27
  jmp alltraps
80106ede:	e9 2d f8 ff ff       	jmp    80106710 <alltraps>

80106ee3 <vector40>:
.globl vector40
vector40:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $40
80106ee5:	6a 28                	push   $0x28
  jmp alltraps
80106ee7:	e9 24 f8 ff ff       	jmp    80106710 <alltraps>

80106eec <vector41>:
.globl vector41
vector41:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $41
80106eee:	6a 29                	push   $0x29
  jmp alltraps
80106ef0:	e9 1b f8 ff ff       	jmp    80106710 <alltraps>

80106ef5 <vector42>:
.globl vector42
vector42:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $42
80106ef7:	6a 2a                	push   $0x2a
  jmp alltraps
80106ef9:	e9 12 f8 ff ff       	jmp    80106710 <alltraps>

80106efe <vector43>:
.globl vector43
vector43:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $43
80106f00:	6a 2b                	push   $0x2b
  jmp alltraps
80106f02:	e9 09 f8 ff ff       	jmp    80106710 <alltraps>

80106f07 <vector44>:
.globl vector44
vector44:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $44
80106f09:	6a 2c                	push   $0x2c
  jmp alltraps
80106f0b:	e9 00 f8 ff ff       	jmp    80106710 <alltraps>

80106f10 <vector45>:
.globl vector45
vector45:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $45
80106f12:	6a 2d                	push   $0x2d
  jmp alltraps
80106f14:	e9 f7 f7 ff ff       	jmp    80106710 <alltraps>

80106f19 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $46
80106f1b:	6a 2e                	push   $0x2e
  jmp alltraps
80106f1d:	e9 ee f7 ff ff       	jmp    80106710 <alltraps>

80106f22 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $47
80106f24:	6a 2f                	push   $0x2f
  jmp alltraps
80106f26:	e9 e5 f7 ff ff       	jmp    80106710 <alltraps>

80106f2b <vector48>:
.globl vector48
vector48:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $48
80106f2d:	6a 30                	push   $0x30
  jmp alltraps
80106f2f:	e9 dc f7 ff ff       	jmp    80106710 <alltraps>

80106f34 <vector49>:
.globl vector49
vector49:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $49
80106f36:	6a 31                	push   $0x31
  jmp alltraps
80106f38:	e9 d3 f7 ff ff       	jmp    80106710 <alltraps>

80106f3d <vector50>:
.globl vector50
vector50:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $50
80106f3f:	6a 32                	push   $0x32
  jmp alltraps
80106f41:	e9 ca f7 ff ff       	jmp    80106710 <alltraps>

80106f46 <vector51>:
.globl vector51
vector51:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $51
80106f48:	6a 33                	push   $0x33
  jmp alltraps
80106f4a:	e9 c1 f7 ff ff       	jmp    80106710 <alltraps>

80106f4f <vector52>:
.globl vector52
vector52:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $52
80106f51:	6a 34                	push   $0x34
  jmp alltraps
80106f53:	e9 b8 f7 ff ff       	jmp    80106710 <alltraps>

80106f58 <vector53>:
.globl vector53
vector53:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $53
80106f5a:	6a 35                	push   $0x35
  jmp alltraps
80106f5c:	e9 af f7 ff ff       	jmp    80106710 <alltraps>

80106f61 <vector54>:
.globl vector54
vector54:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $54
80106f63:	6a 36                	push   $0x36
  jmp alltraps
80106f65:	e9 a6 f7 ff ff       	jmp    80106710 <alltraps>

80106f6a <vector55>:
.globl vector55
vector55:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $55
80106f6c:	6a 37                	push   $0x37
  jmp alltraps
80106f6e:	e9 9d f7 ff ff       	jmp    80106710 <alltraps>

80106f73 <vector56>:
.globl vector56
vector56:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $56
80106f75:	6a 38                	push   $0x38
  jmp alltraps
80106f77:	e9 94 f7 ff ff       	jmp    80106710 <alltraps>

80106f7c <vector57>:
.globl vector57
vector57:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $57
80106f7e:	6a 39                	push   $0x39
  jmp alltraps
80106f80:	e9 8b f7 ff ff       	jmp    80106710 <alltraps>

80106f85 <vector58>:
.globl vector58
vector58:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $58
80106f87:	6a 3a                	push   $0x3a
  jmp alltraps
80106f89:	e9 82 f7 ff ff       	jmp    80106710 <alltraps>

80106f8e <vector59>:
.globl vector59
vector59:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $59
80106f90:	6a 3b                	push   $0x3b
  jmp alltraps
80106f92:	e9 79 f7 ff ff       	jmp    80106710 <alltraps>

80106f97 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $60
80106f99:	6a 3c                	push   $0x3c
  jmp alltraps
80106f9b:	e9 70 f7 ff ff       	jmp    80106710 <alltraps>

80106fa0 <vector61>:
.globl vector61
vector61:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $61
80106fa2:	6a 3d                	push   $0x3d
  jmp alltraps
80106fa4:	e9 67 f7 ff ff       	jmp    80106710 <alltraps>

80106fa9 <vector62>:
.globl vector62
vector62:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $62
80106fab:	6a 3e                	push   $0x3e
  jmp alltraps
80106fad:	e9 5e f7 ff ff       	jmp    80106710 <alltraps>

80106fb2 <vector63>:
.globl vector63
vector63:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $63
80106fb4:	6a 3f                	push   $0x3f
  jmp alltraps
80106fb6:	e9 55 f7 ff ff       	jmp    80106710 <alltraps>

80106fbb <vector64>:
.globl vector64
vector64:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $64
80106fbd:	6a 40                	push   $0x40
  jmp alltraps
80106fbf:	e9 4c f7 ff ff       	jmp    80106710 <alltraps>

80106fc4 <vector65>:
.globl vector65
vector65:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $65
80106fc6:	6a 41                	push   $0x41
  jmp alltraps
80106fc8:	e9 43 f7 ff ff       	jmp    80106710 <alltraps>

80106fcd <vector66>:
.globl vector66
vector66:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $66
80106fcf:	6a 42                	push   $0x42
  jmp alltraps
80106fd1:	e9 3a f7 ff ff       	jmp    80106710 <alltraps>

80106fd6 <vector67>:
.globl vector67
vector67:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $67
80106fd8:	6a 43                	push   $0x43
  jmp alltraps
80106fda:	e9 31 f7 ff ff       	jmp    80106710 <alltraps>

80106fdf <vector68>:
.globl vector68
vector68:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $68
80106fe1:	6a 44                	push   $0x44
  jmp alltraps
80106fe3:	e9 28 f7 ff ff       	jmp    80106710 <alltraps>

80106fe8 <vector69>:
.globl vector69
vector69:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $69
80106fea:	6a 45                	push   $0x45
  jmp alltraps
80106fec:	e9 1f f7 ff ff       	jmp    80106710 <alltraps>

80106ff1 <vector70>:
.globl vector70
vector70:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $70
80106ff3:	6a 46                	push   $0x46
  jmp alltraps
80106ff5:	e9 16 f7 ff ff       	jmp    80106710 <alltraps>

80106ffa <vector71>:
.globl vector71
vector71:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $71
80106ffc:	6a 47                	push   $0x47
  jmp alltraps
80106ffe:	e9 0d f7 ff ff       	jmp    80106710 <alltraps>

80107003 <vector72>:
.globl vector72
vector72:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $72
80107005:	6a 48                	push   $0x48
  jmp alltraps
80107007:	e9 04 f7 ff ff       	jmp    80106710 <alltraps>

8010700c <vector73>:
.globl vector73
vector73:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $73
8010700e:	6a 49                	push   $0x49
  jmp alltraps
80107010:	e9 fb f6 ff ff       	jmp    80106710 <alltraps>

80107015 <vector74>:
.globl vector74
vector74:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $74
80107017:	6a 4a                	push   $0x4a
  jmp alltraps
80107019:	e9 f2 f6 ff ff       	jmp    80106710 <alltraps>

8010701e <vector75>:
.globl vector75
vector75:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $75
80107020:	6a 4b                	push   $0x4b
  jmp alltraps
80107022:	e9 e9 f6 ff ff       	jmp    80106710 <alltraps>

80107027 <vector76>:
.globl vector76
vector76:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $76
80107029:	6a 4c                	push   $0x4c
  jmp alltraps
8010702b:	e9 e0 f6 ff ff       	jmp    80106710 <alltraps>

80107030 <vector77>:
.globl vector77
vector77:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $77
80107032:	6a 4d                	push   $0x4d
  jmp alltraps
80107034:	e9 d7 f6 ff ff       	jmp    80106710 <alltraps>

80107039 <vector78>:
.globl vector78
vector78:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $78
8010703b:	6a 4e                	push   $0x4e
  jmp alltraps
8010703d:	e9 ce f6 ff ff       	jmp    80106710 <alltraps>

80107042 <vector79>:
.globl vector79
vector79:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $79
80107044:	6a 4f                	push   $0x4f
  jmp alltraps
80107046:	e9 c5 f6 ff ff       	jmp    80106710 <alltraps>

8010704b <vector80>:
.globl vector80
vector80:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $80
8010704d:	6a 50                	push   $0x50
  jmp alltraps
8010704f:	e9 bc f6 ff ff       	jmp    80106710 <alltraps>

80107054 <vector81>:
.globl vector81
vector81:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $81
80107056:	6a 51                	push   $0x51
  jmp alltraps
80107058:	e9 b3 f6 ff ff       	jmp    80106710 <alltraps>

8010705d <vector82>:
.globl vector82
vector82:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $82
8010705f:	6a 52                	push   $0x52
  jmp alltraps
80107061:	e9 aa f6 ff ff       	jmp    80106710 <alltraps>

80107066 <vector83>:
.globl vector83
vector83:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $83
80107068:	6a 53                	push   $0x53
  jmp alltraps
8010706a:	e9 a1 f6 ff ff       	jmp    80106710 <alltraps>

8010706f <vector84>:
.globl vector84
vector84:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $84
80107071:	6a 54                	push   $0x54
  jmp alltraps
80107073:	e9 98 f6 ff ff       	jmp    80106710 <alltraps>

80107078 <vector85>:
.globl vector85
vector85:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $85
8010707a:	6a 55                	push   $0x55
  jmp alltraps
8010707c:	e9 8f f6 ff ff       	jmp    80106710 <alltraps>

80107081 <vector86>:
.globl vector86
vector86:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $86
80107083:	6a 56                	push   $0x56
  jmp alltraps
80107085:	e9 86 f6 ff ff       	jmp    80106710 <alltraps>

8010708a <vector87>:
.globl vector87
vector87:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $87
8010708c:	6a 57                	push   $0x57
  jmp alltraps
8010708e:	e9 7d f6 ff ff       	jmp    80106710 <alltraps>

80107093 <vector88>:
.globl vector88
vector88:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $88
80107095:	6a 58                	push   $0x58
  jmp alltraps
80107097:	e9 74 f6 ff ff       	jmp    80106710 <alltraps>

8010709c <vector89>:
.globl vector89
vector89:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $89
8010709e:	6a 59                	push   $0x59
  jmp alltraps
801070a0:	e9 6b f6 ff ff       	jmp    80106710 <alltraps>

801070a5 <vector90>:
.globl vector90
vector90:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $90
801070a7:	6a 5a                	push   $0x5a
  jmp alltraps
801070a9:	e9 62 f6 ff ff       	jmp    80106710 <alltraps>

801070ae <vector91>:
.globl vector91
vector91:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $91
801070b0:	6a 5b                	push   $0x5b
  jmp alltraps
801070b2:	e9 59 f6 ff ff       	jmp    80106710 <alltraps>

801070b7 <vector92>:
.globl vector92
vector92:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $92
801070b9:	6a 5c                	push   $0x5c
  jmp alltraps
801070bb:	e9 50 f6 ff ff       	jmp    80106710 <alltraps>

801070c0 <vector93>:
.globl vector93
vector93:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $93
801070c2:	6a 5d                	push   $0x5d
  jmp alltraps
801070c4:	e9 47 f6 ff ff       	jmp    80106710 <alltraps>

801070c9 <vector94>:
.globl vector94
vector94:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $94
801070cb:	6a 5e                	push   $0x5e
  jmp alltraps
801070cd:	e9 3e f6 ff ff       	jmp    80106710 <alltraps>

801070d2 <vector95>:
.globl vector95
vector95:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $95
801070d4:	6a 5f                	push   $0x5f
  jmp alltraps
801070d6:	e9 35 f6 ff ff       	jmp    80106710 <alltraps>

801070db <vector96>:
.globl vector96
vector96:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $96
801070dd:	6a 60                	push   $0x60
  jmp alltraps
801070df:	e9 2c f6 ff ff       	jmp    80106710 <alltraps>

801070e4 <vector97>:
.globl vector97
vector97:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $97
801070e6:	6a 61                	push   $0x61
  jmp alltraps
801070e8:	e9 23 f6 ff ff       	jmp    80106710 <alltraps>

801070ed <vector98>:
.globl vector98
vector98:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $98
801070ef:	6a 62                	push   $0x62
  jmp alltraps
801070f1:	e9 1a f6 ff ff       	jmp    80106710 <alltraps>

801070f6 <vector99>:
.globl vector99
vector99:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $99
801070f8:	6a 63                	push   $0x63
  jmp alltraps
801070fa:	e9 11 f6 ff ff       	jmp    80106710 <alltraps>

801070ff <vector100>:
.globl vector100
vector100:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $100
80107101:	6a 64                	push   $0x64
  jmp alltraps
80107103:	e9 08 f6 ff ff       	jmp    80106710 <alltraps>

80107108 <vector101>:
.globl vector101
vector101:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $101
8010710a:	6a 65                	push   $0x65
  jmp alltraps
8010710c:	e9 ff f5 ff ff       	jmp    80106710 <alltraps>

80107111 <vector102>:
.globl vector102
vector102:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $102
80107113:	6a 66                	push   $0x66
  jmp alltraps
80107115:	e9 f6 f5 ff ff       	jmp    80106710 <alltraps>

8010711a <vector103>:
.globl vector103
vector103:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $103
8010711c:	6a 67                	push   $0x67
  jmp alltraps
8010711e:	e9 ed f5 ff ff       	jmp    80106710 <alltraps>

80107123 <vector104>:
.globl vector104
vector104:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $104
80107125:	6a 68                	push   $0x68
  jmp alltraps
80107127:	e9 e4 f5 ff ff       	jmp    80106710 <alltraps>

8010712c <vector105>:
.globl vector105
vector105:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $105
8010712e:	6a 69                	push   $0x69
  jmp alltraps
80107130:	e9 db f5 ff ff       	jmp    80106710 <alltraps>

80107135 <vector106>:
.globl vector106
vector106:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $106
80107137:	6a 6a                	push   $0x6a
  jmp alltraps
80107139:	e9 d2 f5 ff ff       	jmp    80106710 <alltraps>

8010713e <vector107>:
.globl vector107
vector107:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $107
80107140:	6a 6b                	push   $0x6b
  jmp alltraps
80107142:	e9 c9 f5 ff ff       	jmp    80106710 <alltraps>

80107147 <vector108>:
.globl vector108
vector108:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $108
80107149:	6a 6c                	push   $0x6c
  jmp alltraps
8010714b:	e9 c0 f5 ff ff       	jmp    80106710 <alltraps>

80107150 <vector109>:
.globl vector109
vector109:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $109
80107152:	6a 6d                	push   $0x6d
  jmp alltraps
80107154:	e9 b7 f5 ff ff       	jmp    80106710 <alltraps>

80107159 <vector110>:
.globl vector110
vector110:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $110
8010715b:	6a 6e                	push   $0x6e
  jmp alltraps
8010715d:	e9 ae f5 ff ff       	jmp    80106710 <alltraps>

80107162 <vector111>:
.globl vector111
vector111:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $111
80107164:	6a 6f                	push   $0x6f
  jmp alltraps
80107166:	e9 a5 f5 ff ff       	jmp    80106710 <alltraps>

8010716b <vector112>:
.globl vector112
vector112:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $112
8010716d:	6a 70                	push   $0x70
  jmp alltraps
8010716f:	e9 9c f5 ff ff       	jmp    80106710 <alltraps>

80107174 <vector113>:
.globl vector113
vector113:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $113
80107176:	6a 71                	push   $0x71
  jmp alltraps
80107178:	e9 93 f5 ff ff       	jmp    80106710 <alltraps>

8010717d <vector114>:
.globl vector114
vector114:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $114
8010717f:	6a 72                	push   $0x72
  jmp alltraps
80107181:	e9 8a f5 ff ff       	jmp    80106710 <alltraps>

80107186 <vector115>:
.globl vector115
vector115:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $115
80107188:	6a 73                	push   $0x73
  jmp alltraps
8010718a:	e9 81 f5 ff ff       	jmp    80106710 <alltraps>

8010718f <vector116>:
.globl vector116
vector116:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $116
80107191:	6a 74                	push   $0x74
  jmp alltraps
80107193:	e9 78 f5 ff ff       	jmp    80106710 <alltraps>

80107198 <vector117>:
.globl vector117
vector117:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $117
8010719a:	6a 75                	push   $0x75
  jmp alltraps
8010719c:	e9 6f f5 ff ff       	jmp    80106710 <alltraps>

801071a1 <vector118>:
.globl vector118
vector118:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $118
801071a3:	6a 76                	push   $0x76
  jmp alltraps
801071a5:	e9 66 f5 ff ff       	jmp    80106710 <alltraps>

801071aa <vector119>:
.globl vector119
vector119:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $119
801071ac:	6a 77                	push   $0x77
  jmp alltraps
801071ae:	e9 5d f5 ff ff       	jmp    80106710 <alltraps>

801071b3 <vector120>:
.globl vector120
vector120:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $120
801071b5:	6a 78                	push   $0x78
  jmp alltraps
801071b7:	e9 54 f5 ff ff       	jmp    80106710 <alltraps>

801071bc <vector121>:
.globl vector121
vector121:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $121
801071be:	6a 79                	push   $0x79
  jmp alltraps
801071c0:	e9 4b f5 ff ff       	jmp    80106710 <alltraps>

801071c5 <vector122>:
.globl vector122
vector122:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $122
801071c7:	6a 7a                	push   $0x7a
  jmp alltraps
801071c9:	e9 42 f5 ff ff       	jmp    80106710 <alltraps>

801071ce <vector123>:
.globl vector123
vector123:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $123
801071d0:	6a 7b                	push   $0x7b
  jmp alltraps
801071d2:	e9 39 f5 ff ff       	jmp    80106710 <alltraps>

801071d7 <vector124>:
.globl vector124
vector124:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $124
801071d9:	6a 7c                	push   $0x7c
  jmp alltraps
801071db:	e9 30 f5 ff ff       	jmp    80106710 <alltraps>

801071e0 <vector125>:
.globl vector125
vector125:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $125
801071e2:	6a 7d                	push   $0x7d
  jmp alltraps
801071e4:	e9 27 f5 ff ff       	jmp    80106710 <alltraps>

801071e9 <vector126>:
.globl vector126
vector126:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $126
801071eb:	6a 7e                	push   $0x7e
  jmp alltraps
801071ed:	e9 1e f5 ff ff       	jmp    80106710 <alltraps>

801071f2 <vector127>:
.globl vector127
vector127:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $127
801071f4:	6a 7f                	push   $0x7f
  jmp alltraps
801071f6:	e9 15 f5 ff ff       	jmp    80106710 <alltraps>

801071fb <vector128>:
.globl vector128
vector128:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $128
801071fd:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107202:	e9 09 f5 ff ff       	jmp    80106710 <alltraps>

80107207 <vector129>:
.globl vector129
vector129:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $129
80107209:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010720e:	e9 fd f4 ff ff       	jmp    80106710 <alltraps>

80107213 <vector130>:
.globl vector130
vector130:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $130
80107215:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010721a:	e9 f1 f4 ff ff       	jmp    80106710 <alltraps>

8010721f <vector131>:
.globl vector131
vector131:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $131
80107221:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107226:	e9 e5 f4 ff ff       	jmp    80106710 <alltraps>

8010722b <vector132>:
.globl vector132
vector132:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $132
8010722d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107232:	e9 d9 f4 ff ff       	jmp    80106710 <alltraps>

80107237 <vector133>:
.globl vector133
vector133:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $133
80107239:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010723e:	e9 cd f4 ff ff       	jmp    80106710 <alltraps>

80107243 <vector134>:
.globl vector134
vector134:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $134
80107245:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010724a:	e9 c1 f4 ff ff       	jmp    80106710 <alltraps>

8010724f <vector135>:
.globl vector135
vector135:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $135
80107251:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107256:	e9 b5 f4 ff ff       	jmp    80106710 <alltraps>

8010725b <vector136>:
.globl vector136
vector136:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $136
8010725d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107262:	e9 a9 f4 ff ff       	jmp    80106710 <alltraps>

80107267 <vector137>:
.globl vector137
vector137:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $137
80107269:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010726e:	e9 9d f4 ff ff       	jmp    80106710 <alltraps>

80107273 <vector138>:
.globl vector138
vector138:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $138
80107275:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010727a:	e9 91 f4 ff ff       	jmp    80106710 <alltraps>

8010727f <vector139>:
.globl vector139
vector139:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $139
80107281:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107286:	e9 85 f4 ff ff       	jmp    80106710 <alltraps>

8010728b <vector140>:
.globl vector140
vector140:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $140
8010728d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107292:	e9 79 f4 ff ff       	jmp    80106710 <alltraps>

80107297 <vector141>:
.globl vector141
vector141:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $141
80107299:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010729e:	e9 6d f4 ff ff       	jmp    80106710 <alltraps>

801072a3 <vector142>:
.globl vector142
vector142:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $142
801072a5:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801072aa:	e9 61 f4 ff ff       	jmp    80106710 <alltraps>

801072af <vector143>:
.globl vector143
vector143:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $143
801072b1:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801072b6:	e9 55 f4 ff ff       	jmp    80106710 <alltraps>

801072bb <vector144>:
.globl vector144
vector144:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $144
801072bd:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801072c2:	e9 49 f4 ff ff       	jmp    80106710 <alltraps>

801072c7 <vector145>:
.globl vector145
vector145:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $145
801072c9:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801072ce:	e9 3d f4 ff ff       	jmp    80106710 <alltraps>

801072d3 <vector146>:
.globl vector146
vector146:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $146
801072d5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801072da:	e9 31 f4 ff ff       	jmp    80106710 <alltraps>

801072df <vector147>:
.globl vector147
vector147:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $147
801072e1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801072e6:	e9 25 f4 ff ff       	jmp    80106710 <alltraps>

801072eb <vector148>:
.globl vector148
vector148:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $148
801072ed:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801072f2:	e9 19 f4 ff ff       	jmp    80106710 <alltraps>

801072f7 <vector149>:
.globl vector149
vector149:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $149
801072f9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801072fe:	e9 0d f4 ff ff       	jmp    80106710 <alltraps>

80107303 <vector150>:
.globl vector150
vector150:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $150
80107305:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010730a:	e9 01 f4 ff ff       	jmp    80106710 <alltraps>

8010730f <vector151>:
.globl vector151
vector151:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $151
80107311:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107316:	e9 f5 f3 ff ff       	jmp    80106710 <alltraps>

8010731b <vector152>:
.globl vector152
vector152:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $152
8010731d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107322:	e9 e9 f3 ff ff       	jmp    80106710 <alltraps>

80107327 <vector153>:
.globl vector153
vector153:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $153
80107329:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010732e:	e9 dd f3 ff ff       	jmp    80106710 <alltraps>

80107333 <vector154>:
.globl vector154
vector154:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $154
80107335:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010733a:	e9 d1 f3 ff ff       	jmp    80106710 <alltraps>

8010733f <vector155>:
.globl vector155
vector155:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $155
80107341:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107346:	e9 c5 f3 ff ff       	jmp    80106710 <alltraps>

8010734b <vector156>:
.globl vector156
vector156:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $156
8010734d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107352:	e9 b9 f3 ff ff       	jmp    80106710 <alltraps>

80107357 <vector157>:
.globl vector157
vector157:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $157
80107359:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010735e:	e9 ad f3 ff ff       	jmp    80106710 <alltraps>

80107363 <vector158>:
.globl vector158
vector158:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $158
80107365:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010736a:	e9 a1 f3 ff ff       	jmp    80106710 <alltraps>

8010736f <vector159>:
.globl vector159
vector159:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $159
80107371:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107376:	e9 95 f3 ff ff       	jmp    80106710 <alltraps>

8010737b <vector160>:
.globl vector160
vector160:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $160
8010737d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107382:	e9 89 f3 ff ff       	jmp    80106710 <alltraps>

80107387 <vector161>:
.globl vector161
vector161:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $161
80107389:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010738e:	e9 7d f3 ff ff       	jmp    80106710 <alltraps>

80107393 <vector162>:
.globl vector162
vector162:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $162
80107395:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010739a:	e9 71 f3 ff ff       	jmp    80106710 <alltraps>

8010739f <vector163>:
.globl vector163
vector163:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $163
801073a1:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801073a6:	e9 65 f3 ff ff       	jmp    80106710 <alltraps>

801073ab <vector164>:
.globl vector164
vector164:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $164
801073ad:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801073b2:	e9 59 f3 ff ff       	jmp    80106710 <alltraps>

801073b7 <vector165>:
.globl vector165
vector165:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $165
801073b9:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801073be:	e9 4d f3 ff ff       	jmp    80106710 <alltraps>

801073c3 <vector166>:
.globl vector166
vector166:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $166
801073c5:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801073ca:	e9 41 f3 ff ff       	jmp    80106710 <alltraps>

801073cf <vector167>:
.globl vector167
vector167:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $167
801073d1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801073d6:	e9 35 f3 ff ff       	jmp    80106710 <alltraps>

801073db <vector168>:
.globl vector168
vector168:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $168
801073dd:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801073e2:	e9 29 f3 ff ff       	jmp    80106710 <alltraps>

801073e7 <vector169>:
.globl vector169
vector169:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $169
801073e9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801073ee:	e9 1d f3 ff ff       	jmp    80106710 <alltraps>

801073f3 <vector170>:
.globl vector170
vector170:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $170
801073f5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801073fa:	e9 11 f3 ff ff       	jmp    80106710 <alltraps>

801073ff <vector171>:
.globl vector171
vector171:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $171
80107401:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107406:	e9 05 f3 ff ff       	jmp    80106710 <alltraps>

8010740b <vector172>:
.globl vector172
vector172:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $172
8010740d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107412:	e9 f9 f2 ff ff       	jmp    80106710 <alltraps>

80107417 <vector173>:
.globl vector173
vector173:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $173
80107419:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010741e:	e9 ed f2 ff ff       	jmp    80106710 <alltraps>

80107423 <vector174>:
.globl vector174
vector174:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $174
80107425:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010742a:	e9 e1 f2 ff ff       	jmp    80106710 <alltraps>

8010742f <vector175>:
.globl vector175
vector175:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $175
80107431:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107436:	e9 d5 f2 ff ff       	jmp    80106710 <alltraps>

8010743b <vector176>:
.globl vector176
vector176:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $176
8010743d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107442:	e9 c9 f2 ff ff       	jmp    80106710 <alltraps>

80107447 <vector177>:
.globl vector177
vector177:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $177
80107449:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010744e:	e9 bd f2 ff ff       	jmp    80106710 <alltraps>

80107453 <vector178>:
.globl vector178
vector178:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $178
80107455:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010745a:	e9 b1 f2 ff ff       	jmp    80106710 <alltraps>

8010745f <vector179>:
.globl vector179
vector179:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $179
80107461:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107466:	e9 a5 f2 ff ff       	jmp    80106710 <alltraps>

8010746b <vector180>:
.globl vector180
vector180:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $180
8010746d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107472:	e9 99 f2 ff ff       	jmp    80106710 <alltraps>

80107477 <vector181>:
.globl vector181
vector181:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $181
80107479:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010747e:	e9 8d f2 ff ff       	jmp    80106710 <alltraps>

80107483 <vector182>:
.globl vector182
vector182:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $182
80107485:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010748a:	e9 81 f2 ff ff       	jmp    80106710 <alltraps>

8010748f <vector183>:
.globl vector183
vector183:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $183
80107491:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107496:	e9 75 f2 ff ff       	jmp    80106710 <alltraps>

8010749b <vector184>:
.globl vector184
vector184:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $184
8010749d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801074a2:	e9 69 f2 ff ff       	jmp    80106710 <alltraps>

801074a7 <vector185>:
.globl vector185
vector185:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $185
801074a9:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801074ae:	e9 5d f2 ff ff       	jmp    80106710 <alltraps>

801074b3 <vector186>:
.globl vector186
vector186:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $186
801074b5:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801074ba:	e9 51 f2 ff ff       	jmp    80106710 <alltraps>

801074bf <vector187>:
.globl vector187
vector187:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $187
801074c1:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801074c6:	e9 45 f2 ff ff       	jmp    80106710 <alltraps>

801074cb <vector188>:
.globl vector188
vector188:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $188
801074cd:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801074d2:	e9 39 f2 ff ff       	jmp    80106710 <alltraps>

801074d7 <vector189>:
.globl vector189
vector189:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $189
801074d9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801074de:	e9 2d f2 ff ff       	jmp    80106710 <alltraps>

801074e3 <vector190>:
.globl vector190
vector190:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $190
801074e5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801074ea:	e9 21 f2 ff ff       	jmp    80106710 <alltraps>

801074ef <vector191>:
.globl vector191
vector191:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $191
801074f1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801074f6:	e9 15 f2 ff ff       	jmp    80106710 <alltraps>

801074fb <vector192>:
.globl vector192
vector192:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $192
801074fd:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107502:	e9 09 f2 ff ff       	jmp    80106710 <alltraps>

80107507 <vector193>:
.globl vector193
vector193:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $193
80107509:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010750e:	e9 fd f1 ff ff       	jmp    80106710 <alltraps>

80107513 <vector194>:
.globl vector194
vector194:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $194
80107515:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010751a:	e9 f1 f1 ff ff       	jmp    80106710 <alltraps>

8010751f <vector195>:
.globl vector195
vector195:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $195
80107521:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107526:	e9 e5 f1 ff ff       	jmp    80106710 <alltraps>

8010752b <vector196>:
.globl vector196
vector196:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $196
8010752d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107532:	e9 d9 f1 ff ff       	jmp    80106710 <alltraps>

80107537 <vector197>:
.globl vector197
vector197:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $197
80107539:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010753e:	e9 cd f1 ff ff       	jmp    80106710 <alltraps>

80107543 <vector198>:
.globl vector198
vector198:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $198
80107545:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010754a:	e9 c1 f1 ff ff       	jmp    80106710 <alltraps>

8010754f <vector199>:
.globl vector199
vector199:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $199
80107551:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107556:	e9 b5 f1 ff ff       	jmp    80106710 <alltraps>

8010755b <vector200>:
.globl vector200
vector200:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $200
8010755d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107562:	e9 a9 f1 ff ff       	jmp    80106710 <alltraps>

80107567 <vector201>:
.globl vector201
vector201:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $201
80107569:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010756e:	e9 9d f1 ff ff       	jmp    80106710 <alltraps>

80107573 <vector202>:
.globl vector202
vector202:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $202
80107575:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010757a:	e9 91 f1 ff ff       	jmp    80106710 <alltraps>

8010757f <vector203>:
.globl vector203
vector203:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $203
80107581:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107586:	e9 85 f1 ff ff       	jmp    80106710 <alltraps>

8010758b <vector204>:
.globl vector204
vector204:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $204
8010758d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107592:	e9 79 f1 ff ff       	jmp    80106710 <alltraps>

80107597 <vector205>:
.globl vector205
vector205:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $205
80107599:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010759e:	e9 6d f1 ff ff       	jmp    80106710 <alltraps>

801075a3 <vector206>:
.globl vector206
vector206:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $206
801075a5:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801075aa:	e9 61 f1 ff ff       	jmp    80106710 <alltraps>

801075af <vector207>:
.globl vector207
vector207:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $207
801075b1:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801075b6:	e9 55 f1 ff ff       	jmp    80106710 <alltraps>

801075bb <vector208>:
.globl vector208
vector208:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $208
801075bd:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801075c2:	e9 49 f1 ff ff       	jmp    80106710 <alltraps>

801075c7 <vector209>:
.globl vector209
vector209:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $209
801075c9:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801075ce:	e9 3d f1 ff ff       	jmp    80106710 <alltraps>

801075d3 <vector210>:
.globl vector210
vector210:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $210
801075d5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801075da:	e9 31 f1 ff ff       	jmp    80106710 <alltraps>

801075df <vector211>:
.globl vector211
vector211:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $211
801075e1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801075e6:	e9 25 f1 ff ff       	jmp    80106710 <alltraps>

801075eb <vector212>:
.globl vector212
vector212:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $212
801075ed:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801075f2:	e9 19 f1 ff ff       	jmp    80106710 <alltraps>

801075f7 <vector213>:
.globl vector213
vector213:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $213
801075f9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801075fe:	e9 0d f1 ff ff       	jmp    80106710 <alltraps>

80107603 <vector214>:
.globl vector214
vector214:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $214
80107605:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010760a:	e9 01 f1 ff ff       	jmp    80106710 <alltraps>

8010760f <vector215>:
.globl vector215
vector215:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $215
80107611:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107616:	e9 f5 f0 ff ff       	jmp    80106710 <alltraps>

8010761b <vector216>:
.globl vector216
vector216:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $216
8010761d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107622:	e9 e9 f0 ff ff       	jmp    80106710 <alltraps>

80107627 <vector217>:
.globl vector217
vector217:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $217
80107629:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010762e:	e9 dd f0 ff ff       	jmp    80106710 <alltraps>

80107633 <vector218>:
.globl vector218
vector218:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $218
80107635:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010763a:	e9 d1 f0 ff ff       	jmp    80106710 <alltraps>

8010763f <vector219>:
.globl vector219
vector219:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $219
80107641:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107646:	e9 c5 f0 ff ff       	jmp    80106710 <alltraps>

8010764b <vector220>:
.globl vector220
vector220:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $220
8010764d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107652:	e9 b9 f0 ff ff       	jmp    80106710 <alltraps>

80107657 <vector221>:
.globl vector221
vector221:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $221
80107659:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010765e:	e9 ad f0 ff ff       	jmp    80106710 <alltraps>

80107663 <vector222>:
.globl vector222
vector222:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $222
80107665:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010766a:	e9 a1 f0 ff ff       	jmp    80106710 <alltraps>

8010766f <vector223>:
.globl vector223
vector223:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $223
80107671:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107676:	e9 95 f0 ff ff       	jmp    80106710 <alltraps>

8010767b <vector224>:
.globl vector224
vector224:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $224
8010767d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107682:	e9 89 f0 ff ff       	jmp    80106710 <alltraps>

80107687 <vector225>:
.globl vector225
vector225:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $225
80107689:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010768e:	e9 7d f0 ff ff       	jmp    80106710 <alltraps>

80107693 <vector226>:
.globl vector226
vector226:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $226
80107695:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010769a:	e9 71 f0 ff ff       	jmp    80106710 <alltraps>

8010769f <vector227>:
.globl vector227
vector227:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $227
801076a1:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801076a6:	e9 65 f0 ff ff       	jmp    80106710 <alltraps>

801076ab <vector228>:
.globl vector228
vector228:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $228
801076ad:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801076b2:	e9 59 f0 ff ff       	jmp    80106710 <alltraps>

801076b7 <vector229>:
.globl vector229
vector229:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $229
801076b9:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801076be:	e9 4d f0 ff ff       	jmp    80106710 <alltraps>

801076c3 <vector230>:
.globl vector230
vector230:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $230
801076c5:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801076ca:	e9 41 f0 ff ff       	jmp    80106710 <alltraps>

801076cf <vector231>:
.globl vector231
vector231:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $231
801076d1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801076d6:	e9 35 f0 ff ff       	jmp    80106710 <alltraps>

801076db <vector232>:
.globl vector232
vector232:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $232
801076dd:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801076e2:	e9 29 f0 ff ff       	jmp    80106710 <alltraps>

801076e7 <vector233>:
.globl vector233
vector233:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $233
801076e9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801076ee:	e9 1d f0 ff ff       	jmp    80106710 <alltraps>

801076f3 <vector234>:
.globl vector234
vector234:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $234
801076f5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801076fa:	e9 11 f0 ff ff       	jmp    80106710 <alltraps>

801076ff <vector235>:
.globl vector235
vector235:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $235
80107701:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107706:	e9 05 f0 ff ff       	jmp    80106710 <alltraps>

8010770b <vector236>:
.globl vector236
vector236:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $236
8010770d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107712:	e9 f9 ef ff ff       	jmp    80106710 <alltraps>

80107717 <vector237>:
.globl vector237
vector237:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $237
80107719:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010771e:	e9 ed ef ff ff       	jmp    80106710 <alltraps>

80107723 <vector238>:
.globl vector238
vector238:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $238
80107725:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010772a:	e9 e1 ef ff ff       	jmp    80106710 <alltraps>

8010772f <vector239>:
.globl vector239
vector239:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $239
80107731:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107736:	e9 d5 ef ff ff       	jmp    80106710 <alltraps>

8010773b <vector240>:
.globl vector240
vector240:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $240
8010773d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107742:	e9 c9 ef ff ff       	jmp    80106710 <alltraps>

80107747 <vector241>:
.globl vector241
vector241:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $241
80107749:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010774e:	e9 bd ef ff ff       	jmp    80106710 <alltraps>

80107753 <vector242>:
.globl vector242
vector242:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $242
80107755:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010775a:	e9 b1 ef ff ff       	jmp    80106710 <alltraps>

8010775f <vector243>:
.globl vector243
vector243:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $243
80107761:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107766:	e9 a5 ef ff ff       	jmp    80106710 <alltraps>

8010776b <vector244>:
.globl vector244
vector244:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $244
8010776d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107772:	e9 99 ef ff ff       	jmp    80106710 <alltraps>

80107777 <vector245>:
.globl vector245
vector245:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $245
80107779:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010777e:	e9 8d ef ff ff       	jmp    80106710 <alltraps>

80107783 <vector246>:
.globl vector246
vector246:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $246
80107785:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010778a:	e9 81 ef ff ff       	jmp    80106710 <alltraps>

8010778f <vector247>:
.globl vector247
vector247:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $247
80107791:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107796:	e9 75 ef ff ff       	jmp    80106710 <alltraps>

8010779b <vector248>:
.globl vector248
vector248:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $248
8010779d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801077a2:	e9 69 ef ff ff       	jmp    80106710 <alltraps>

801077a7 <vector249>:
.globl vector249
vector249:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $249
801077a9:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801077ae:	e9 5d ef ff ff       	jmp    80106710 <alltraps>

801077b3 <vector250>:
.globl vector250
vector250:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $250
801077b5:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801077ba:	e9 51 ef ff ff       	jmp    80106710 <alltraps>

801077bf <vector251>:
.globl vector251
vector251:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $251
801077c1:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801077c6:	e9 45 ef ff ff       	jmp    80106710 <alltraps>

801077cb <vector252>:
.globl vector252
vector252:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $252
801077cd:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801077d2:	e9 39 ef ff ff       	jmp    80106710 <alltraps>

801077d7 <vector253>:
.globl vector253
vector253:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $253
801077d9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801077de:	e9 2d ef ff ff       	jmp    80106710 <alltraps>

801077e3 <vector254>:
.globl vector254
vector254:
  pushl $0
801077e3:	6a 00                	push   $0x0
  pushl $254
801077e5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801077ea:	e9 21 ef ff ff       	jmp    80106710 <alltraps>

801077ef <vector255>:
.globl vector255
vector255:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $255
801077f1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801077f6:	e9 15 ef ff ff       	jmp    80106710 <alltraps>

801077fb <sgenrand>:
static int mti=N+1; /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void
sgenrand(unsigned long seed)
{
801077fb:	55                   	push   %ebp
801077fc:	89 e5                	mov    %esp,%ebp
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0]= seed & 0xffffffff;
801077fe:	8b 45 08             	mov    0x8(%ebp),%eax
80107801:	a3 80 b6 10 80       	mov    %eax,0x8010b680
    for (mti=1; mti<N; mti++)
80107806:	c7 05 a0 b4 10 80 01 	movl   $0x1,0x8010b4a0
8010780d:	00 00 00 
80107810:	eb 2f                	jmp    80107841 <sgenrand+0x46>
        mt[mti] = (69069 * mt[mti-1]) & 0xffffffff;
80107812:	a1 a0 b4 10 80       	mov    0x8010b4a0,%eax
80107817:	8b 15 a0 b4 10 80    	mov    0x8010b4a0,%edx
8010781d:	83 ea 01             	sub    $0x1,%edx
80107820:	8b 14 95 80 b6 10 80 	mov    -0x7fef4980(,%edx,4),%edx
80107827:	69 d2 cd 0d 01 00    	imul   $0x10dcd,%edx,%edx
8010782d:	89 14 85 80 b6 10 80 	mov    %edx,-0x7fef4980(,%eax,4)
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0]= seed & 0xffffffff;
    for (mti=1; mti<N; mti++)
80107834:	a1 a0 b4 10 80       	mov    0x8010b4a0,%eax
80107839:	83 c0 01             	add    $0x1,%eax
8010783c:	a3 a0 b4 10 80       	mov    %eax,0x8010b4a0
80107841:	a1 a0 b4 10 80       	mov    0x8010b4a0,%eax
80107846:	3d 6f 02 00 00       	cmp    $0x26f,%eax
8010784b:	7e c5                	jle    80107812 <sgenrand+0x17>
        mt[mti] = (69069 * mt[mti-1]) & 0xffffffff;
}
8010784d:	5d                   	pop    %ebp
8010784e:	c3                   	ret    

8010784f <genrand>:

long /* for integer generation */
genrand()
{
8010784f:	55                   	push   %ebp
80107850:	89 e5                	mov    %esp,%ebp
80107852:	83 ec 14             	sub    $0x14,%esp
    unsigned long y;
    static unsigned long mag01[2]={0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N) { /* generate N words at one time */
80107855:	a1 a0 b4 10 80       	mov    0x8010b4a0,%eax
8010785a:	3d 6f 02 00 00       	cmp    $0x26f,%eax
8010785f:	0f 8e 30 01 00 00    	jle    80107995 <genrand+0x146>
        int kk;

        if (mti == N+1)   /* if sgenrand() has not been called, */
80107865:	a1 a0 b4 10 80       	mov    0x8010b4a0,%eax
8010786a:	3d 71 02 00 00       	cmp    $0x271,%eax
8010786f:	75 0c                	jne    8010787d <genrand+0x2e>
            sgenrand(4357); /* a default initial seed is used   */
80107871:	c7 04 24 05 11 00 00 	movl   $0x1105,(%esp)
80107878:	e8 7e ff ff ff       	call   801077fb <sgenrand>

        for (kk=0;kk<N-M;kk++) {
8010787d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80107884:	eb 5b                	jmp    801078e1 <genrand+0x92>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
80107886:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107889:	8b 04 85 80 b6 10 80 	mov    -0x7fef4980(,%eax,4),%eax
80107890:	25 00 00 00 80       	and    $0x80000000,%eax
80107895:	89 c2                	mov    %eax,%edx
80107897:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010789a:	83 c0 01             	add    $0x1,%eax
8010789d:	8b 04 85 80 b6 10 80 	mov    -0x7fef4980(,%eax,4),%eax
801078a4:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
801078a9:	09 d0                	or     %edx,%eax
801078ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1];
801078ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801078b1:	05 8d 01 00 00       	add    $0x18d,%eax
801078b6:	8b 04 85 80 b6 10 80 	mov    -0x7fef4980(,%eax,4),%eax
801078bd:	8b 55 f8             	mov    -0x8(%ebp),%edx
801078c0:	d1 ea                	shr    %edx
801078c2:	31 c2                	xor    %eax,%edx
801078c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801078c7:	83 e0 01             	and    $0x1,%eax
801078ca:	8b 04 85 a4 b4 10 80 	mov    -0x7fef4b5c(,%eax,4),%eax
801078d1:	31 c2                	xor    %eax,%edx
801078d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801078d6:	89 14 85 80 b6 10 80 	mov    %edx,-0x7fef4980(,%eax,4)
        int kk;

        if (mti == N+1)   /* if sgenrand() has not been called, */
            sgenrand(4357); /* a default initial seed is used   */

        for (kk=0;kk<N-M;kk++) {
801078dd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801078e1:	81 7d fc e2 00 00 00 	cmpl   $0xe2,-0x4(%ebp)
801078e8:	7e 9c                	jle    80107886 <genrand+0x37>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1];
        }
        for (;kk<N-1;kk++) {
801078ea:	eb 5b                	jmp    80107947 <genrand+0xf8>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
801078ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801078ef:	8b 04 85 80 b6 10 80 	mov    -0x7fef4980(,%eax,4),%eax
801078f6:	25 00 00 00 80       	and    $0x80000000,%eax
801078fb:	89 c2                	mov    %eax,%edx
801078fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107900:	83 c0 01             	add    $0x1,%eax
80107903:	8b 04 85 80 b6 10 80 	mov    -0x7fef4980(,%eax,4),%eax
8010790a:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
8010790f:	09 d0                	or     %edx,%eax
80107911:	89 45 f8             	mov    %eax,-0x8(%ebp)
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1];
80107914:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107917:	2d e3 00 00 00       	sub    $0xe3,%eax
8010791c:	8b 04 85 80 b6 10 80 	mov    -0x7fef4980(,%eax,4),%eax
80107923:	8b 55 f8             	mov    -0x8(%ebp),%edx
80107926:	d1 ea                	shr    %edx
80107928:	31 c2                	xor    %eax,%edx
8010792a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010792d:	83 e0 01             	and    $0x1,%eax
80107930:	8b 04 85 a4 b4 10 80 	mov    -0x7fef4b5c(,%eax,4),%eax
80107937:	31 c2                	xor    %eax,%edx
80107939:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010793c:	89 14 85 80 b6 10 80 	mov    %edx,-0x7fef4980(,%eax,4)

        for (kk=0;kk<N-M;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1];
        }
        for (;kk<N-1;kk++) {
80107943:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80107947:	81 7d fc 6e 02 00 00 	cmpl   $0x26e,-0x4(%ebp)
8010794e:	7e 9c                	jle    801078ec <genrand+0x9d>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1];
        }
        y = (mt[N-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
80107950:	a1 3c c0 10 80       	mov    0x8010c03c,%eax
80107955:	25 00 00 00 80       	and    $0x80000000,%eax
8010795a:	89 c2                	mov    %eax,%edx
8010795c:	a1 80 b6 10 80       	mov    0x8010b680,%eax
80107961:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
80107966:	09 d0                	or     %edx,%eax
80107968:	89 45 f8             	mov    %eax,-0x8(%ebp)
        mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 0x1];
8010796b:	a1 b0 bc 10 80       	mov    0x8010bcb0,%eax
80107970:	8b 55 f8             	mov    -0x8(%ebp),%edx
80107973:	d1 ea                	shr    %edx
80107975:	31 c2                	xor    %eax,%edx
80107977:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010797a:	83 e0 01             	and    $0x1,%eax
8010797d:	8b 04 85 a4 b4 10 80 	mov    -0x7fef4b5c(,%eax,4),%eax
80107984:	31 d0                	xor    %edx,%eax
80107986:	a3 3c c0 10 80       	mov    %eax,0x8010c03c

        mti = 0;
8010798b:	c7 05 a0 b4 10 80 00 	movl   $0x0,0x8010b4a0
80107992:	00 00 00 
    }
  
    y = mt[mti++];
80107995:	a1 a0 b4 10 80       	mov    0x8010b4a0,%eax
8010799a:	8d 50 01             	lea    0x1(%eax),%edx
8010799d:	89 15 a0 b4 10 80    	mov    %edx,0x8010b4a0
801079a3:	8b 04 85 80 b6 10 80 	mov    -0x7fef4980(,%eax,4),%eax
801079aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
    y ^= TEMPERING_SHIFT_U(y);
801079ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
801079b0:	c1 e8 0b             	shr    $0xb,%eax
801079b3:	31 45 f8             	xor    %eax,-0x8(%ebp)
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
801079b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801079b9:	c1 e0 07             	shl    $0x7,%eax
801079bc:	25 80 56 2c 9d       	and    $0x9d2c5680,%eax
801079c1:	31 45 f8             	xor    %eax,-0x8(%ebp)
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
801079c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801079c7:	c1 e0 0f             	shl    $0xf,%eax
801079ca:	25 00 00 c6 ef       	and    $0xefc60000,%eax
801079cf:	31 45 f8             	xor    %eax,-0x8(%ebp)
    y ^= TEMPERING_SHIFT_L(y);
801079d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801079d5:	c1 e8 12             	shr    $0x12,%eax
801079d8:	31 45 f8             	xor    %eax,-0x8(%ebp)

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
801079db:	8b 45 f8             	mov    -0x8(%ebp),%eax
801079de:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
}
801079e3:	c9                   	leave  
801079e4:	c3                   	ret    

801079e5 <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max) {
801079e5:	55                   	push   %ebp
801079e6:	89 e5                	mov    %esp,%ebp
801079e8:	83 ec 20             	sub    $0x20,%esp
  unsigned long
    // max <= RAND_MAX < ULONG_MAX, so this is okay.
    num_bins = (unsigned long) max + 1,
801079eb:	8b 45 08             	mov    0x8(%ebp),%eax
801079ee:	83 c0 01             	add    $0x1,%eax
801079f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    num_rand = (unsigned long) RAND_MAX + 1,
801079f4:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
    bin_size = num_rand / num_bins,
801079fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801079fe:	ba 00 00 00 00       	mov    $0x0,%edx
80107a03:	f7 75 fc             	divl   -0x4(%ebp)
80107a06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    defect   = num_rand % num_bins;
80107a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107a0c:	ba 00 00 00 00       	mov    $0x0,%edx
80107a11:	f7 75 fc             	divl   -0x4(%ebp)
80107a14:	89 55 f0             	mov    %edx,-0x10(%ebp)

  long x;
  do {
   x = genrand();
80107a17:	e8 33 fe ff ff       	call   8010784f <genrand>
80107a1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }
  // This is carefully written not to overflow
  while (num_rand - defect <= (unsigned long)x);
80107a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a22:	8b 55 f8             	mov    -0x8(%ebp),%edx
80107a25:	29 c2                	sub    %eax,%edx
80107a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a2a:	39 c2                	cmp    %eax,%edx
80107a2c:	76 e9                	jbe    80107a17 <random_at_most+0x32>

  // Truncated division is intentional
  return x/bin_size;
80107a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a31:	ba 00 00 00 00       	mov    $0x0,%edx
80107a36:	f7 75 f4             	divl   -0xc(%ebp)
}
80107a39:	c9                   	leave  
80107a3a:	c3                   	ret    

80107a3b <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107a3b:	55                   	push   %ebp
80107a3c:	89 e5                	mov    %esp,%ebp
80107a3e:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107a41:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a44:	83 e8 01             	sub    $0x1,%eax
80107a47:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a4e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a52:	8b 45 08             	mov    0x8(%ebp),%eax
80107a55:	c1 e8 10             	shr    $0x10,%eax
80107a58:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107a5c:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a5f:	0f 01 10             	lgdtl  (%eax)
}
80107a62:	c9                   	leave  
80107a63:	c3                   	ret    

80107a64 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a64:	55                   	push   %ebp
80107a65:	89 e5                	mov    %esp,%ebp
80107a67:	83 ec 04             	sub    $0x4,%esp
80107a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a6d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a71:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a75:	0f 00 d8             	ltr    %ax
}
80107a78:	c9                   	leave  
80107a79:	c3                   	ret    

80107a7a <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a7a:	55                   	push   %ebp
80107a7b:	89 e5                	mov    %esp,%ebp
80107a7d:	83 ec 04             	sub    $0x4,%esp
80107a80:	8b 45 08             	mov    0x8(%ebp),%eax
80107a83:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a87:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a8b:	8e e8                	mov    %eax,%gs
}
80107a8d:	c9                   	leave  
80107a8e:	c3                   	ret    

80107a8f <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a8f:	55                   	push   %ebp
80107a90:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a92:	8b 45 08             	mov    0x8(%ebp),%eax
80107a95:	0f 22 d8             	mov    %eax,%cr3
}
80107a98:	5d                   	pop    %ebp
80107a99:	c3                   	ret    

80107a9a <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a9a:	55                   	push   %ebp
80107a9b:	89 e5                	mov    %esp,%ebp
80107a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80107aa0:	05 00 00 00 80       	add    $0x80000000,%eax
80107aa5:	5d                   	pop    %ebp
80107aa6:	c3                   	ret    

80107aa7 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107aa7:	55                   	push   %ebp
80107aa8:	89 e5                	mov    %esp,%ebp
80107aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80107aad:	05 00 00 00 80       	add    $0x80000000,%eax
80107ab2:	5d                   	pop    %ebp
80107ab3:	c3                   	ret    

80107ab4 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107ab4:	55                   	push   %ebp
80107ab5:	89 e5                	mov    %esp,%ebp
80107ab7:	53                   	push   %ebx
80107ab8:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107abb:	e8 0b b5 ff ff       	call   80102fcb <cpunum>
80107ac0:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107ac6:	05 40 2d 11 80       	add    $0x80112d40,%eax
80107acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad1:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ada:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae3:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aea:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aee:	83 e2 f0             	and    $0xfffffff0,%edx
80107af1:	83 ca 0a             	or     $0xa,%edx
80107af4:	88 50 7d             	mov    %dl,0x7d(%eax)
80107af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afa:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107afe:	83 ca 10             	or     $0x10,%edx
80107b01:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b07:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b0b:	83 e2 9f             	and    $0xffffff9f,%edx
80107b0e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b14:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b18:	83 ca 80             	or     $0xffffff80,%edx
80107b1b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b21:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b25:	83 ca 0f             	or     $0xf,%edx
80107b28:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b32:	83 e2 ef             	and    $0xffffffef,%edx
80107b35:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b3f:	83 e2 df             	and    $0xffffffdf,%edx
80107b42:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b4c:	83 ca 40             	or     $0x40,%edx
80107b4f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b55:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b59:	83 ca 80             	or     $0xffffff80,%edx
80107b5c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b69:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b70:	ff ff 
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b7c:	00 00 
80107b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b81:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b92:	83 e2 f0             	and    $0xfffffff0,%edx
80107b95:	83 ca 02             	or     $0x2,%edx
80107b98:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ba8:	83 ca 10             	or     $0x10,%edx
80107bab:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bbb:	83 e2 9f             	and    $0xffffff9f,%edx
80107bbe:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bce:	83 ca 80             	or     $0xffffff80,%edx
80107bd1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107be1:	83 ca 0f             	or     $0xf,%edx
80107be4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bed:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bf4:	83 e2 ef             	and    $0xffffffef,%edx
80107bf7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c00:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c07:	83 e2 df             	and    $0xffffffdf,%edx
80107c0a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c1a:	83 ca 40             	or     $0x40,%edx
80107c1d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c2d:	83 ca 80             	or     $0xffffff80,%edx
80107c30:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c39:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c43:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c4a:	ff ff 
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c56:	00 00 
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c65:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c6c:	83 e2 f0             	and    $0xfffffff0,%edx
80107c6f:	83 ca 0a             	or     $0xa,%edx
80107c72:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c82:	83 ca 10             	or     $0x10,%edx
80107c85:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c95:	83 ca 60             	or     $0x60,%edx
80107c98:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ca8:	83 ca 80             	or     $0xffffff80,%edx
80107cab:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cbb:	83 ca 0f             	or     $0xf,%edx
80107cbe:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cce:	83 e2 ef             	and    $0xffffffef,%edx
80107cd1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cda:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ce1:	83 e2 df             	and    $0xffffffdf,%edx
80107ce4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ced:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cf4:	83 ca 40             	or     $0x40,%edx
80107cf7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d00:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d07:	83 ca 80             	or     $0xffffff80,%edx
80107d0a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d13:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1d:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107d24:	ff ff 
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107d30:	00 00 
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d46:	83 e2 f0             	and    $0xfffffff0,%edx
80107d49:	83 ca 02             	or     $0x2,%edx
80107d4c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d55:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d5c:	83 ca 10             	or     $0x10,%edx
80107d5f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d68:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d6f:	83 ca 60             	or     $0x60,%edx
80107d72:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d82:	83 ca 80             	or     $0xffffff80,%edx
80107d85:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d95:	83 ca 0f             	or     $0xf,%edx
80107d98:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107da8:	83 e2 ef             	and    $0xffffffef,%edx
80107dab:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107dbb:	83 e2 df             	and    $0xffffffdf,%edx
80107dbe:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107dce:	83 ca 40             	or     $0x40,%edx
80107dd1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dda:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107de1:	83 ca 80             	or     $0xffffff80,%edx
80107de4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ded:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df7:	05 b4 00 00 00       	add    $0xb4,%eax
80107dfc:	89 c3                	mov    %eax,%ebx
80107dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e01:	05 b4 00 00 00       	add    $0xb4,%eax
80107e06:	c1 e8 10             	shr    $0x10,%eax
80107e09:	89 c1                	mov    %eax,%ecx
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	05 b4 00 00 00       	add    $0xb4,%eax
80107e13:	c1 e8 18             	shr    $0x18,%eax
80107e16:	89 c2                	mov    %eax,%edx
80107e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1b:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107e22:	00 00 
80107e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e27:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e31:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3a:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e41:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e44:	83 c9 02             	or     $0x2,%ecx
80107e47:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e50:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e57:	83 c9 10             	or     $0x10,%ecx
80107e5a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e63:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e6a:	83 e1 9f             	and    $0xffffff9f,%ecx
80107e6d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e76:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e7d:	83 c9 80             	or     $0xffffff80,%ecx
80107e80:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e89:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e90:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e93:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ea3:	83 e1 ef             	and    $0xffffffef,%ecx
80107ea6:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaf:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107eb6:	83 e1 df             	and    $0xffffffdf,%ecx
80107eb9:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ec9:	83 c9 40             	or     $0x40,%ecx
80107ecc:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107edc:	83 c9 80             	or     $0xffffff80,%ecx
80107edf:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee8:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef1:	83 c0 70             	add    $0x70,%eax
80107ef4:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107efb:	00 
80107efc:	89 04 24             	mov    %eax,(%esp)
80107eff:	e8 37 fb ff ff       	call   80107a3b <lgdt>
  loadgs(SEG_KCPU << 3);
80107f04:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107f0b:	e8 6a fb ff ff       	call   80107a7a <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f13:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107f19:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107f20:	00 00 00 00 
}
80107f24:	83 c4 24             	add    $0x24,%esp
80107f27:	5b                   	pop    %ebx
80107f28:	5d                   	pop    %ebp
80107f29:	c3                   	ret    

80107f2a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f2a:	55                   	push   %ebp
80107f2b:	89 e5                	mov    %esp,%ebp
80107f2d:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f30:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f33:	c1 e8 16             	shr    $0x16,%eax
80107f36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80107f40:	01 d0                	add    %edx,%eax
80107f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f48:	8b 00                	mov    (%eax),%eax
80107f4a:	83 e0 01             	and    $0x1,%eax
80107f4d:	85 c0                	test   %eax,%eax
80107f4f:	74 17                	je     80107f68 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f54:	8b 00                	mov    (%eax),%eax
80107f56:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f5b:	89 04 24             	mov    %eax,(%esp)
80107f5e:	e8 44 fb ff ff       	call   80107aa7 <p2v>
80107f63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f66:	eb 4b                	jmp    80107fb3 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f6c:	74 0e                	je     80107f7c <walkpgdir+0x52>
80107f6e:	e8 c2 ac ff ff       	call   80102c35 <kalloc>
80107f73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f7a:	75 07                	jne    80107f83 <walkpgdir+0x59>
      return 0;
80107f7c:	b8 00 00 00 00       	mov    $0x0,%eax
80107f81:	eb 47                	jmp    80107fca <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f83:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f8a:	00 
80107f8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f92:	00 
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	89 04 24             	mov    %eax,(%esp)
80107f99:	e8 01 d3 ff ff       	call   8010529f <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa1:	89 04 24             	mov    %eax,(%esp)
80107fa4:	e8 f1 fa ff ff       	call   80107a9a <v2p>
80107fa9:	83 c8 07             	or     $0x7,%eax
80107fac:	89 c2                	mov    %eax,%edx
80107fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb1:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fb6:	c1 e8 0c             	shr    $0xc,%eax
80107fb9:	25 ff 03 00 00       	and    $0x3ff,%eax
80107fbe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc8:	01 d0                	add    %edx,%eax
}
80107fca:	c9                   	leave  
80107fcb:	c3                   	ret    

80107fcc <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107fcc:	55                   	push   %ebp
80107fcd:	89 e5                	mov    %esp,%ebp
80107fcf:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fd5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fda:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107fdd:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fe0:	8b 45 10             	mov    0x10(%ebp),%eax
80107fe3:	01 d0                	add    %edx,%eax
80107fe5:	83 e8 01             	sub    $0x1,%eax
80107fe8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ff0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107ff7:	00 
80107ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fff:	8b 45 08             	mov    0x8(%ebp),%eax
80108002:	89 04 24             	mov    %eax,(%esp)
80108005:	e8 20 ff ff ff       	call   80107f2a <walkpgdir>
8010800a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010800d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108011:	75 07                	jne    8010801a <mappages+0x4e>
      return -1;
80108013:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108018:	eb 48                	jmp    80108062 <mappages+0x96>
    if(*pte & PTE_P)
8010801a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010801d:	8b 00                	mov    (%eax),%eax
8010801f:	83 e0 01             	and    $0x1,%eax
80108022:	85 c0                	test   %eax,%eax
80108024:	74 0c                	je     80108032 <mappages+0x66>
      panic("remap");
80108026:	c7 04 24 d4 8e 10 80 	movl   $0x80108ed4,(%esp)
8010802d:	e8 a5 85 ff ff       	call   801005d7 <panic>
    *pte = pa | perm | PTE_P;
80108032:	8b 45 18             	mov    0x18(%ebp),%eax
80108035:	0b 45 14             	or     0x14(%ebp),%eax
80108038:	83 c8 01             	or     $0x1,%eax
8010803b:	89 c2                	mov    %eax,%edx
8010803d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108040:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108045:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108048:	75 08                	jne    80108052 <mappages+0x86>
      break;
8010804a:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010804b:	b8 00 00 00 00       	mov    $0x0,%eax
80108050:	eb 10                	jmp    80108062 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108052:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108059:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108060:	eb 8e                	jmp    80107ff0 <mappages+0x24>
  return 0;
}
80108062:	c9                   	leave  
80108063:	c3                   	ret    

80108064 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108064:	55                   	push   %ebp
80108065:	89 e5                	mov    %esp,%ebp
80108067:	53                   	push   %ebx
80108068:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010806b:	e8 c5 ab ff ff       	call   80102c35 <kalloc>
80108070:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108073:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108077:	75 0a                	jne    80108083 <setupkvm+0x1f>
    return 0;
80108079:	b8 00 00 00 00       	mov    $0x0,%eax
8010807e:	e9 98 00 00 00       	jmp    8010811b <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108083:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010808a:	00 
8010808b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108092:	00 
80108093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108096:	89 04 24             	mov    %eax,(%esp)
80108099:	e8 01 d2 ff ff       	call   8010529f <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010809e:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801080a5:	e8 fd f9 ff ff       	call   80107aa7 <p2v>
801080aa:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801080af:	76 0c                	jbe    801080bd <setupkvm+0x59>
    panic("PHYSTOP too high");
801080b1:	c7 04 24 da 8e 10 80 	movl   $0x80108eda,(%esp)
801080b8:	e8 1a 85 ff ff       	call   801005d7 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080bd:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
801080c4:	eb 49                	jmp    8010810f <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801080c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c9:	8b 48 0c             	mov    0xc(%eax),%ecx
801080cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cf:	8b 50 04             	mov    0x4(%eax),%edx
801080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d5:	8b 58 08             	mov    0x8(%eax),%ebx
801080d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080db:	8b 40 04             	mov    0x4(%eax),%eax
801080de:	29 c3                	sub    %eax,%ebx
801080e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e3:	8b 00                	mov    (%eax),%eax
801080e5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801080e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
801080ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801080f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801080f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080f8:	89 04 24             	mov    %eax,(%esp)
801080fb:	e8 cc fe ff ff       	call   80107fcc <mappages>
80108100:	85 c0                	test   %eax,%eax
80108102:	79 07                	jns    8010810b <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108104:	b8 00 00 00 00       	mov    $0x0,%eax
80108109:	eb 10                	jmp    8010811b <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010810b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010810f:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80108116:	72 ae                	jb     801080c6 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108118:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010811b:	83 c4 34             	add    $0x34,%esp
8010811e:	5b                   	pop    %ebx
8010811f:	5d                   	pop    %ebp
80108120:	c3                   	ret    

80108121 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108121:	55                   	push   %ebp
80108122:	89 e5                	mov    %esp,%ebp
80108124:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108127:	e8 38 ff ff ff       	call   80108064 <setupkvm>
8010812c:	a3 18 5c 11 80       	mov    %eax,0x80115c18
  switchkvm();
80108131:	e8 02 00 00 00       	call   80108138 <switchkvm>
}
80108136:	c9                   	leave  
80108137:	c3                   	ret    

80108138 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108138:	55                   	push   %ebp
80108139:	89 e5                	mov    %esp,%ebp
8010813b:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010813e:	a1 18 5c 11 80       	mov    0x80115c18,%eax
80108143:	89 04 24             	mov    %eax,(%esp)
80108146:	e8 4f f9 ff ff       	call   80107a9a <v2p>
8010814b:	89 04 24             	mov    %eax,(%esp)
8010814e:	e8 3c f9 ff ff       	call   80107a8f <lcr3>
}
80108153:	c9                   	leave  
80108154:	c3                   	ret    

80108155 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108155:	55                   	push   %ebp
80108156:	89 e5                	mov    %esp,%ebp
80108158:	53                   	push   %ebx
80108159:	83 ec 14             	sub    $0x14,%esp
  pushcli();
8010815c:	e8 3e d0 ff ff       	call   8010519f <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108161:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108167:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010816e:	83 c2 08             	add    $0x8,%edx
80108171:	89 d3                	mov    %edx,%ebx
80108173:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010817a:	83 c2 08             	add    $0x8,%edx
8010817d:	c1 ea 10             	shr    $0x10,%edx
80108180:	89 d1                	mov    %edx,%ecx
80108182:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108189:	83 c2 08             	add    $0x8,%edx
8010818c:	c1 ea 18             	shr    $0x18,%edx
8010818f:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108196:	67 00 
80108198:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010819f:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801081a5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081ac:	83 e1 f0             	and    $0xfffffff0,%ecx
801081af:	83 c9 09             	or     $0x9,%ecx
801081b2:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081b8:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081bf:	83 c9 10             	or     $0x10,%ecx
801081c2:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081c8:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081cf:	83 e1 9f             	and    $0xffffff9f,%ecx
801081d2:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081d8:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081df:	83 c9 80             	or     $0xffffff80,%ecx
801081e2:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081e8:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081ef:	83 e1 f0             	and    $0xfffffff0,%ecx
801081f2:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081f8:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081ff:	83 e1 ef             	and    $0xffffffef,%ecx
80108202:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108208:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010820f:	83 e1 df             	and    $0xffffffdf,%ecx
80108212:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108218:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010821f:	83 c9 40             	or     $0x40,%ecx
80108222:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108228:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010822f:	83 e1 7f             	and    $0x7f,%ecx
80108232:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108238:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010823e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108244:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010824b:	83 e2 ef             	and    $0xffffffef,%edx
8010824e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108254:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010825a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108260:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108266:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010826d:	8b 52 08             	mov    0x8(%edx),%edx
80108270:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108276:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108279:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108280:	e8 df f7 ff ff       	call   80107a64 <ltr>
  if(p->pgdir == 0)
80108285:	8b 45 08             	mov    0x8(%ebp),%eax
80108288:	8b 40 04             	mov    0x4(%eax),%eax
8010828b:	85 c0                	test   %eax,%eax
8010828d:	75 0c                	jne    8010829b <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010828f:	c7 04 24 eb 8e 10 80 	movl   $0x80108eeb,(%esp)
80108296:	e8 3c 83 ff ff       	call   801005d7 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010829b:	8b 45 08             	mov    0x8(%ebp),%eax
8010829e:	8b 40 04             	mov    0x4(%eax),%eax
801082a1:	89 04 24             	mov    %eax,(%esp)
801082a4:	e8 f1 f7 ff ff       	call   80107a9a <v2p>
801082a9:	89 04 24             	mov    %eax,(%esp)
801082ac:	e8 de f7 ff ff       	call   80107a8f <lcr3>
  popcli();
801082b1:	e8 2d cf ff ff       	call   801051e3 <popcli>
}
801082b6:	83 c4 14             	add    $0x14,%esp
801082b9:	5b                   	pop    %ebx
801082ba:	5d                   	pop    %ebp
801082bb:	c3                   	ret    

801082bc <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801082bc:	55                   	push   %ebp
801082bd:	89 e5                	mov    %esp,%ebp
801082bf:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801082c2:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801082c9:	76 0c                	jbe    801082d7 <inituvm+0x1b>
    panic("inituvm: more than a page");
801082cb:	c7 04 24 ff 8e 10 80 	movl   $0x80108eff,(%esp)
801082d2:	e8 00 83 ff ff       	call   801005d7 <panic>
  mem = kalloc();
801082d7:	e8 59 a9 ff ff       	call   80102c35 <kalloc>
801082dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801082df:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082e6:	00 
801082e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082ee:	00 
801082ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f2:	89 04 24             	mov    %eax,(%esp)
801082f5:	e8 a5 cf ff ff       	call   8010529f <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fd:	89 04 24             	mov    %eax,(%esp)
80108300:	e8 95 f7 ff ff       	call   80107a9a <v2p>
80108305:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010830c:	00 
8010830d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108311:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108318:	00 
80108319:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108320:	00 
80108321:	8b 45 08             	mov    0x8(%ebp),%eax
80108324:	89 04 24             	mov    %eax,(%esp)
80108327:	e8 a0 fc ff ff       	call   80107fcc <mappages>
  memmove(mem, init, sz);
8010832c:	8b 45 10             	mov    0x10(%ebp),%eax
8010832f:	89 44 24 08          	mov    %eax,0x8(%esp)
80108333:	8b 45 0c             	mov    0xc(%ebp),%eax
80108336:	89 44 24 04          	mov    %eax,0x4(%esp)
8010833a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833d:	89 04 24             	mov    %eax,(%esp)
80108340:	e8 29 d0 ff ff       	call   8010536e <memmove>
}
80108345:	c9                   	leave  
80108346:	c3                   	ret    

80108347 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108347:	55                   	push   %ebp
80108348:	89 e5                	mov    %esp,%ebp
8010834a:	53                   	push   %ebx
8010834b:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010834e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108351:	25 ff 0f 00 00       	and    $0xfff,%eax
80108356:	85 c0                	test   %eax,%eax
80108358:	74 0c                	je     80108366 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010835a:	c7 04 24 1c 8f 10 80 	movl   $0x80108f1c,(%esp)
80108361:	e8 71 82 ff ff       	call   801005d7 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108366:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010836d:	e9 a9 00 00 00       	jmp    8010841b <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108375:	8b 55 0c             	mov    0xc(%ebp),%edx
80108378:	01 d0                	add    %edx,%eax
8010837a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108381:	00 
80108382:	89 44 24 04          	mov    %eax,0x4(%esp)
80108386:	8b 45 08             	mov    0x8(%ebp),%eax
80108389:	89 04 24             	mov    %eax,(%esp)
8010838c:	e8 99 fb ff ff       	call   80107f2a <walkpgdir>
80108391:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108394:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108398:	75 0c                	jne    801083a6 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010839a:	c7 04 24 3f 8f 10 80 	movl   $0x80108f3f,(%esp)
801083a1:	e8 31 82 ff ff       	call   801005d7 <panic>
    pa = PTE_ADDR(*pte);
801083a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a9:	8b 00                	mov    (%eax),%eax
801083ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801083b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b6:	8b 55 18             	mov    0x18(%ebp),%edx
801083b9:	29 c2                	sub    %eax,%edx
801083bb:	89 d0                	mov    %edx,%eax
801083bd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801083c2:	77 0f                	ja     801083d3 <loaduvm+0x8c>
      n = sz - i;
801083c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c7:	8b 55 18             	mov    0x18(%ebp),%edx
801083ca:	29 c2                	sub    %eax,%edx
801083cc:	89 d0                	mov    %edx,%eax
801083ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083d1:	eb 07                	jmp    801083da <loaduvm+0x93>
    else
      n = PGSIZE;
801083d3:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801083da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083dd:	8b 55 14             	mov    0x14(%ebp),%edx
801083e0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801083e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083e6:	89 04 24             	mov    %eax,(%esp)
801083e9:	e8 b9 f6 ff ff       	call   80107aa7 <p2v>
801083ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
801083f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801083f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801083fd:	8b 45 10             	mov    0x10(%ebp),%eax
80108400:	89 04 24             	mov    %eax,(%esp)
80108403:	e8 7c 9a ff ff       	call   80101e84 <readi>
80108408:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010840b:	74 07                	je     80108414 <loaduvm+0xcd>
      return -1;
8010840d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108412:	eb 18                	jmp    8010842c <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108414:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	3b 45 18             	cmp    0x18(%ebp),%eax
80108421:	0f 82 4b ff ff ff    	jb     80108372 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108427:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010842c:	83 c4 24             	add    $0x24,%esp
8010842f:	5b                   	pop    %ebx
80108430:	5d                   	pop    %ebp
80108431:	c3                   	ret    

80108432 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108432:	55                   	push   %ebp
80108433:	89 e5                	mov    %esp,%ebp
80108435:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108438:	8b 45 10             	mov    0x10(%ebp),%eax
8010843b:	85 c0                	test   %eax,%eax
8010843d:	79 0a                	jns    80108449 <allocuvm+0x17>
    return 0;
8010843f:	b8 00 00 00 00       	mov    $0x0,%eax
80108444:	e9 c1 00 00 00       	jmp    8010850a <allocuvm+0xd8>
  if(newsz < oldsz)
80108449:	8b 45 10             	mov    0x10(%ebp),%eax
8010844c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010844f:	73 08                	jae    80108459 <allocuvm+0x27>
    return oldsz;
80108451:	8b 45 0c             	mov    0xc(%ebp),%eax
80108454:	e9 b1 00 00 00       	jmp    8010850a <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108459:	8b 45 0c             	mov    0xc(%ebp),%eax
8010845c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108461:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108466:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108469:	e9 8d 00 00 00       	jmp    801084fb <allocuvm+0xc9>
    mem = kalloc();
8010846e:	e8 c2 a7 ff ff       	call   80102c35 <kalloc>
80108473:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108476:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010847a:	75 2c                	jne    801084a8 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
8010847c:	c7 04 24 5d 8f 10 80 	movl   $0x80108f5d,(%esp)
80108483:	e8 7b 7f ff ff       	call   80100403 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108488:	8b 45 0c             	mov    0xc(%ebp),%eax
8010848b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010848f:	8b 45 10             	mov    0x10(%ebp),%eax
80108492:	89 44 24 04          	mov    %eax,0x4(%esp)
80108496:	8b 45 08             	mov    0x8(%ebp),%eax
80108499:	89 04 24             	mov    %eax,(%esp)
8010849c:	e8 6b 00 00 00       	call   8010850c <deallocuvm>
      return 0;
801084a1:	b8 00 00 00 00       	mov    $0x0,%eax
801084a6:	eb 62                	jmp    8010850a <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801084a8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084af:	00 
801084b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084b7:	00 
801084b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084bb:	89 04 24             	mov    %eax,(%esp)
801084be:	e8 dc cd ff ff       	call   8010529f <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801084c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c6:	89 04 24             	mov    %eax,(%esp)
801084c9:	e8 cc f5 ff ff       	call   80107a9a <v2p>
801084ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084d1:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801084d8:	00 
801084d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
801084dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084e4:	00 
801084e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801084e9:	8b 45 08             	mov    0x8(%ebp),%eax
801084ec:	89 04 24             	mov    %eax,(%esp)
801084ef:	e8 d8 fa ff ff       	call   80107fcc <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801084f4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fe:	3b 45 10             	cmp    0x10(%ebp),%eax
80108501:	0f 82 67 ff ff ff    	jb     8010846e <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108507:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010850a:	c9                   	leave  
8010850b:	c3                   	ret    

8010850c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010850c:	55                   	push   %ebp
8010850d:	89 e5                	mov    %esp,%ebp
8010850f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108512:	8b 45 10             	mov    0x10(%ebp),%eax
80108515:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108518:	72 08                	jb     80108522 <deallocuvm+0x16>
    return oldsz;
8010851a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010851d:	e9 a4 00 00 00       	jmp    801085c6 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108522:	8b 45 10             	mov    0x10(%ebp),%eax
80108525:	05 ff 0f 00 00       	add    $0xfff,%eax
8010852a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010852f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108532:	e9 80 00 00 00       	jmp    801085b7 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108541:	00 
80108542:	89 44 24 04          	mov    %eax,0x4(%esp)
80108546:	8b 45 08             	mov    0x8(%ebp),%eax
80108549:	89 04 24             	mov    %eax,(%esp)
8010854c:	e8 d9 f9 ff ff       	call   80107f2a <walkpgdir>
80108551:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108554:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108558:	75 09                	jne    80108563 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010855a:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108561:	eb 4d                	jmp    801085b0 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108563:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108566:	8b 00                	mov    (%eax),%eax
80108568:	83 e0 01             	and    $0x1,%eax
8010856b:	85 c0                	test   %eax,%eax
8010856d:	74 41                	je     801085b0 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
8010856f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108572:	8b 00                	mov    (%eax),%eax
80108574:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108579:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010857c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108580:	75 0c                	jne    8010858e <deallocuvm+0x82>
        panic("kfree");
80108582:	c7 04 24 75 8f 10 80 	movl   $0x80108f75,(%esp)
80108589:	e8 49 80 ff ff       	call   801005d7 <panic>
      char *v = p2v(pa);
8010858e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108591:	89 04 24             	mov    %eax,(%esp)
80108594:	e8 0e f5 ff ff       	call   80107aa7 <p2v>
80108599:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010859c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010859f:	89 04 24             	mov    %eax,(%esp)
801085a2:	e8 f5 a5 ff ff       	call   80102b9c <kfree>
      *pte = 0;
801085a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801085b0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085bd:	0f 82 74 ff ff ff    	jb     80108537 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801085c3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801085c6:	c9                   	leave  
801085c7:	c3                   	ret    

801085c8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801085c8:	55                   	push   %ebp
801085c9:	89 e5                	mov    %esp,%ebp
801085cb:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801085ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801085d2:	75 0c                	jne    801085e0 <freevm+0x18>
    panic("freevm: no pgdir");
801085d4:	c7 04 24 7b 8f 10 80 	movl   $0x80108f7b,(%esp)
801085db:	e8 f7 7f ff ff       	call   801005d7 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801085e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085e7:	00 
801085e8:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801085ef:	80 
801085f0:	8b 45 08             	mov    0x8(%ebp),%eax
801085f3:	89 04 24             	mov    %eax,(%esp)
801085f6:	e8 11 ff ff ff       	call   8010850c <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801085fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108602:	eb 48                	jmp    8010864c <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108607:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010860e:	8b 45 08             	mov    0x8(%ebp),%eax
80108611:	01 d0                	add    %edx,%eax
80108613:	8b 00                	mov    (%eax),%eax
80108615:	83 e0 01             	and    $0x1,%eax
80108618:	85 c0                	test   %eax,%eax
8010861a:	74 2c                	je     80108648 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010861c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108626:	8b 45 08             	mov    0x8(%ebp),%eax
80108629:	01 d0                	add    %edx,%eax
8010862b:	8b 00                	mov    (%eax),%eax
8010862d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108632:	89 04 24             	mov    %eax,(%esp)
80108635:	e8 6d f4 ff ff       	call   80107aa7 <p2v>
8010863a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010863d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108640:	89 04 24             	mov    %eax,(%esp)
80108643:	e8 54 a5 ff ff       	call   80102b9c <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108648:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010864c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108653:	76 af                	jbe    80108604 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108655:	8b 45 08             	mov    0x8(%ebp),%eax
80108658:	89 04 24             	mov    %eax,(%esp)
8010865b:	e8 3c a5 ff ff       	call   80102b9c <kfree>
}
80108660:	c9                   	leave  
80108661:	c3                   	ret    

80108662 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108662:	55                   	push   %ebp
80108663:	89 e5                	mov    %esp,%ebp
80108665:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108668:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010866f:	00 
80108670:	8b 45 0c             	mov    0xc(%ebp),%eax
80108673:	89 44 24 04          	mov    %eax,0x4(%esp)
80108677:	8b 45 08             	mov    0x8(%ebp),%eax
8010867a:	89 04 24             	mov    %eax,(%esp)
8010867d:	e8 a8 f8 ff ff       	call   80107f2a <walkpgdir>
80108682:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108685:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108689:	75 0c                	jne    80108697 <clearpteu+0x35>
    panic("clearpteu");
8010868b:	c7 04 24 8c 8f 10 80 	movl   $0x80108f8c,(%esp)
80108692:	e8 40 7f ff ff       	call   801005d7 <panic>
  *pte &= ~PTE_U;
80108697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869a:	8b 00                	mov    (%eax),%eax
8010869c:	83 e0 fb             	and    $0xfffffffb,%eax
8010869f:	89 c2                	mov    %eax,%edx
801086a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a4:	89 10                	mov    %edx,(%eax)
}
801086a6:	c9                   	leave  
801086a7:	c3                   	ret    

801086a8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801086a8:	55                   	push   %ebp
801086a9:	89 e5                	mov    %esp,%ebp
801086ab:	53                   	push   %ebx
801086ac:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801086af:	e8 b0 f9 ff ff       	call   80108064 <setupkvm>
801086b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801086b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086bb:	75 0a                	jne    801086c7 <copyuvm+0x1f>
    return 0;
801086bd:	b8 00 00 00 00       	mov    $0x0,%eax
801086c2:	e9 fd 00 00 00       	jmp    801087c4 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801086c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086ce:	e9 d0 00 00 00       	jmp    801087a3 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086dd:	00 
801086de:	89 44 24 04          	mov    %eax,0x4(%esp)
801086e2:	8b 45 08             	mov    0x8(%ebp),%eax
801086e5:	89 04 24             	mov    %eax,(%esp)
801086e8:	e8 3d f8 ff ff       	call   80107f2a <walkpgdir>
801086ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086f4:	75 0c                	jne    80108702 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801086f6:	c7 04 24 96 8f 10 80 	movl   $0x80108f96,(%esp)
801086fd:	e8 d5 7e ff ff       	call   801005d7 <panic>
    if(!(*pte & PTE_P))
80108702:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108705:	8b 00                	mov    (%eax),%eax
80108707:	83 e0 01             	and    $0x1,%eax
8010870a:	85 c0                	test   %eax,%eax
8010870c:	75 0c                	jne    8010871a <copyuvm+0x72>
      panic("copyuvm: page not present");
8010870e:	c7 04 24 b0 8f 10 80 	movl   $0x80108fb0,(%esp)
80108715:	e8 bd 7e ff ff       	call   801005d7 <panic>
    pa = PTE_ADDR(*pte);
8010871a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010871d:	8b 00                	mov    (%eax),%eax
8010871f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108724:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010872a:	8b 00                	mov    (%eax),%eax
8010872c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108731:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108734:	e8 fc a4 ff ff       	call   80102c35 <kalloc>
80108739:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010873c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108740:	75 02                	jne    80108744 <copyuvm+0x9c>
      goto bad;
80108742:	eb 70                	jmp    801087b4 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108744:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108747:	89 04 24             	mov    %eax,(%esp)
8010874a:	e8 58 f3 ff ff       	call   80107aa7 <p2v>
8010874f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108756:	00 
80108757:	89 44 24 04          	mov    %eax,0x4(%esp)
8010875b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010875e:	89 04 24             	mov    %eax,(%esp)
80108761:	e8 08 cc ff ff       	call   8010536e <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108766:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108769:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010876c:	89 04 24             	mov    %eax,(%esp)
8010876f:	e8 26 f3 ff ff       	call   80107a9a <v2p>
80108774:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108777:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010877b:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010877f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108786:	00 
80108787:	89 54 24 04          	mov    %edx,0x4(%esp)
8010878b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010878e:	89 04 24             	mov    %eax,(%esp)
80108791:	e8 36 f8 ff ff       	call   80107fcc <mappages>
80108796:	85 c0                	test   %eax,%eax
80108798:	79 02                	jns    8010879c <copyuvm+0xf4>
      goto bad;
8010879a:	eb 18                	jmp    801087b4 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010879c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087a9:	0f 82 24 ff ff ff    	jb     801086d3 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801087af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b2:	eb 10                	jmp    801087c4 <copyuvm+0x11c>

bad:
  freevm(d);
801087b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b7:	89 04 24             	mov    %eax,(%esp)
801087ba:	e8 09 fe ff ff       	call   801085c8 <freevm>
  return 0;
801087bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087c4:	83 c4 44             	add    $0x44,%esp
801087c7:	5b                   	pop    %ebx
801087c8:	5d                   	pop    %ebp
801087c9:	c3                   	ret    

801087ca <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801087ca:	55                   	push   %ebp
801087cb:	89 e5                	mov    %esp,%ebp
801087cd:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087d7:	00 
801087d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801087db:	89 44 24 04          	mov    %eax,0x4(%esp)
801087df:	8b 45 08             	mov    0x8(%ebp),%eax
801087e2:	89 04 24             	mov    %eax,(%esp)
801087e5:	e8 40 f7 ff ff       	call   80107f2a <walkpgdir>
801087ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801087ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f0:	8b 00                	mov    (%eax),%eax
801087f2:	83 e0 01             	and    $0x1,%eax
801087f5:	85 c0                	test   %eax,%eax
801087f7:	75 07                	jne    80108800 <uva2ka+0x36>
    return 0;
801087f9:	b8 00 00 00 00       	mov    $0x0,%eax
801087fe:	eb 25                	jmp    80108825 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108803:	8b 00                	mov    (%eax),%eax
80108805:	83 e0 04             	and    $0x4,%eax
80108808:	85 c0                	test   %eax,%eax
8010880a:	75 07                	jne    80108813 <uva2ka+0x49>
    return 0;
8010880c:	b8 00 00 00 00       	mov    $0x0,%eax
80108811:	eb 12                	jmp    80108825 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108816:	8b 00                	mov    (%eax),%eax
80108818:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010881d:	89 04 24             	mov    %eax,(%esp)
80108820:	e8 82 f2 ff ff       	call   80107aa7 <p2v>
}
80108825:	c9                   	leave  
80108826:	c3                   	ret    

80108827 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108827:	55                   	push   %ebp
80108828:	89 e5                	mov    %esp,%ebp
8010882a:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010882d:	8b 45 10             	mov    0x10(%ebp),%eax
80108830:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108833:	e9 87 00 00 00       	jmp    801088bf <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010883b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108840:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108843:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108846:	89 44 24 04          	mov    %eax,0x4(%esp)
8010884a:	8b 45 08             	mov    0x8(%ebp),%eax
8010884d:	89 04 24             	mov    %eax,(%esp)
80108850:	e8 75 ff ff ff       	call   801087ca <uva2ka>
80108855:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108858:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010885c:	75 07                	jne    80108865 <copyout+0x3e>
      return -1;
8010885e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108863:	eb 69                	jmp    801088ce <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108865:	8b 45 0c             	mov    0xc(%ebp),%eax
80108868:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010886b:	29 c2                	sub    %eax,%edx
8010886d:	89 d0                	mov    %edx,%eax
8010886f:	05 00 10 00 00       	add    $0x1000,%eax
80108874:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010887a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010887d:	76 06                	jbe    80108885 <copyout+0x5e>
      n = len;
8010887f:	8b 45 14             	mov    0x14(%ebp),%eax
80108882:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108885:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108888:	8b 55 0c             	mov    0xc(%ebp),%edx
8010888b:	29 c2                	sub    %eax,%edx
8010888d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108890:	01 c2                	add    %eax,%edx
80108892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108895:	89 44 24 08          	mov    %eax,0x8(%esp)
80108899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889c:	89 44 24 04          	mov    %eax,0x4(%esp)
801088a0:	89 14 24             	mov    %edx,(%esp)
801088a3:	e8 c6 ca ff ff       	call   8010536e <memmove>
    len -= n;
801088a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ab:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801088ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088b1:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801088b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088b7:	05 00 10 00 00       	add    $0x1000,%eax
801088bc:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801088bf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801088c3:	0f 85 6f ff ff ff    	jne    80108838 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801088c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088ce:	c9                   	leave  
801088cf:	c3                   	ret    

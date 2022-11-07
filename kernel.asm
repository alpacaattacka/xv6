
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

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
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 8f 38 10 80       	mov    $0x8010388f,%eax
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
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 14 88 10 80       	push   $0x80108814
80100042:	68 60 c6 10 80       	push   $0x8010c660
80100047:	e8 81 52 00 00       	call   801052cd <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 05 11 80       	mov    0x80110574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 05 11 80       	mov    $0x80110564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 c6 10 80       	push   $0x8010c660
801000c1:	e8 29 52 00 00       	call   801052ef <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 05 11 80       	mov    0x80110574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 c6 10 80       	push   $0x8010c660
8010010c:	e8 45 52 00 00       	call   80105356 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 c6 10 80       	push   $0x8010c660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 c1 4e 00 00       	call   80104fed <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 05 11 80       	mov    0x80110570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 c6 10 80       	push   $0x8010c660
80100188:	e8 c9 51 00 00       	call   80105356 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 1b 88 10 80       	push   $0x8010881b
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 26 27 00 00       	call   8010290d <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 2c 88 10 80       	push   $0x8010882c
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 e5 26 00 00       	call   8010290d <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 33 88 10 80       	push   $0x80108833
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 c6 10 80       	push   $0x8010c660
80100255:	e8 95 50 00 00       	call   801052ef <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 05 11 80       	mov    0x80110574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 1d 4e 00 00       	call   801050db <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 c6 10 80       	push   $0x8010c660
801002c9:	e8 88 50 00 00       	call   80105356 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 b5 10 80       	push   $0x8010b5c0
801003e2:	e8 08 4f 00 00       	call   801052ef <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 3a 88 10 80       	push   $0x8010883a
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 43 88 10 80 	movl   $0x80108843,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 b5 10 80       	push   $0x8010b5c0
8010055b:	e8 f6 4d 00 00       	call   80105356 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 4a 88 10 80       	push   $0x8010884a
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 59 88 10 80       	push   $0x80108859
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 e1 4d 00 00       	call   801053a8 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 5b 88 10 80       	push   $0x8010885b
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 5f 88 10 80       	push   $0x8010885f
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 90 10 80       	mov    0x80109000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 15 4f 00 00       	call   80105611 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 2c 4e 00 00       	call   80105552 <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 e1 66 00 00       	call   80106e9c <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 d4 66 00 00       	call   80106e9c <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 c7 66 00 00       	call   80106e9c <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 b7 66 00 00       	call   80106e9c <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 c0 b5 10 80       	push   $0x8010b5c0
8010080e:	e8 dc 4a 00 00       	call   801052ef <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 08 08 11 80       	mov    0x80110808,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 08 08 11 80       	mov    %eax,0x80110808
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 08 08 11 80    	mov    0x80110808,%edx
80100870:	a1 04 08 11 80       	mov    0x80110804,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 08 08 11 80       	mov    0x80110808,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 80 07 11 80 	movzbl -0x7feef880(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 08 08 11 80    	mov    0x80110808,%edx
8010089e:	a1 04 08 11 80       	mov    0x80110804,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 08 08 11 80       	mov    0x80110808,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 08 08 11 80       	mov    %eax,0x80110808
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 08 08 11 80    	mov    0x80110808,%edx
801008dd:	a1 00 08 11 80       	mov    0x80110800,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 08 08 11 80       	mov    0x80110808,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 08 08 11 80    	mov    %edx,0x80110808
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 80 07 11 80    	mov    %dl,-0x7feef880(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 08 08 11 80       	mov    0x80110808,%eax
80100937:	8b 15 00 08 11 80    	mov    0x80110800,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 08 08 11 80       	mov    0x80110808,%eax
80100949:	a3 04 08 11 80       	mov    %eax,0x80110804
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 00 08 11 80       	push   $0x80110800
80100956:	e8 80 47 00 00       	call   801050db <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 c0 b5 10 80       	push   $0x8010b5c0
80100979:	e8 d8 49 00 00       	call   80105356 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 0d 48 00 00       	call   80105199 <procdump>
  }
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 28 11 00 00       	call   80101ac8 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 b5 10 80       	push   $0x8010b5c0
801009b1:	e8 39 49 00 00       	call   801052ef <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 c0 b5 10 80       	push   $0x8010b5c0
801009d3:	e8 7e 49 00 00       	call   80105356 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 84 0f 00 00       	call   8010196a <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 b5 10 80       	push   $0x8010b5c0
801009fb:	68 00 08 11 80       	push   $0x80110800
80100a00:	e8 e8 45 00 00       	call   80104fed <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 00 08 11 80    	mov    0x80110800,%edx
80100a0e:	a1 04 08 11 80       	mov    0x80110804,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 00 08 11 80       	mov    0x80110800,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 00 08 11 80    	mov    %edx,0x80110800
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 80 07 11 80 	movzbl -0x7feef880(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 00 08 11 80       	mov    0x80110800,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 00 08 11 80       	mov    %eax,0x80110800
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a7e:	e8 d3 48 00 00       	call   80105356 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 d9 0e 00 00       	call   8010196a <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 17 10 00 00       	call   80101ac8 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 b5 10 80       	push   $0x8010b5c0
80100abc:	e8 2e 48 00 00       	call   801052ef <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 c0 b5 10 80       	push   $0x8010b5c0
80100afe:	e8 53 48 00 00       	call   80105356 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 59 0e 00 00       	call   8010196a <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 72 88 10 80       	push   $0x80108872
80100b27:	68 c0 b5 10 80       	push   $0x8010b5c0
80100b2c:	e8 9c 47 00 00       	call   801052cd <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 cc 11 11 80 a0 	movl   $0x80100aa0,0x801111cc
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 c8 11 11 80 8f 	movl   $0x8010098f,0x801111c8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 cf 33 00 00       	call   80103f2b <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 6f 1f 00 00       	call   80102ada <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 ce 29 00 00       	call   8010354d <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 9e 19 00 00       	call   80102528 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 3e 2a 00 00       	call   801035d9 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 ce 03 00 00       	jmp    80100f73 <exec+0x402>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 ba 0d 00 00       	call   8010196a <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 0b 13 00 00       	call   80101ed8 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 49 03 00 00    	jbe    80100f22 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 3b 03 00 00    	jne    80100f25 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 02 74 00 00       	call   80107ff1 <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 2c 03 00 00    	je     80100f28 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100bfc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c0a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c13:	e9 ab 00 00 00       	jmp    80100cc3 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c1b:	6a 20                	push   $0x20
80100c1d:	50                   	push   %eax
80100c1e:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c24:	50                   	push   %eax
80100c25:	ff 75 d8             	pushl  -0x28(%ebp)
80100c28:	e8 ab 12 00 00       	call   80101ed8 <readi>
80100c2d:	83 c4 10             	add    $0x10,%esp
80100c30:	83 f8 20             	cmp    $0x20,%eax
80100c33:	0f 85 f2 02 00 00    	jne    80100f2b <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c39:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3f:	83 f8 01             	cmp    $0x1,%eax
80100c42:	75 71                	jne    80100cb5 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c44:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c4a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c50:	39 c2                	cmp    %eax,%edx
80100c52:	0f 82 d6 02 00 00    	jb     80100f2e <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c58:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c5e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c64:	01 d0                	add    %edx,%eax
80100c66:	83 ec 04             	sub    $0x4,%esp
80100c69:	50                   	push   %eax
80100c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80100c6d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c70:	e8 23 77 00 00       	call   80108398 <allocuvm>
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c7f:	0f 84 ac 02 00 00    	je     80100f31 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c91:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	52                   	push   %edx
80100c9b:	50                   	push   %eax
80100c9c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c9f:	51                   	push   %ecx
80100ca0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ca3:	e8 19 76 00 00       	call   801082c1 <loaduvm>
80100ca8:	83 c4 20             	add    $0x20,%esp
80100cab:	85 c0                	test   %eax,%eax
80100cad:	0f 88 81 02 00 00    	js     80100f34 <exec+0x3c3>
80100cb3:	eb 01                	jmp    80100cb6 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100cb5:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	83 c0 20             	add    $0x20,%eax
80100cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc3:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cca:	0f b7 c0             	movzwl %ax,%eax
80100ccd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cd0:	0f 8f 42 ff ff ff    	jg     80100c18 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cd6:	83 ec 0c             	sub    $0xc,%esp
80100cd9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cdc:	e8 49 0f 00 00       	call   80101c2a <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ce4:	e8 f0 28 00 00       	call   801035d9 <end_op>
  ip = 0;
80100ce9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d03:	05 00 20 00 00       	add    $0x2000,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 81 76 00 00       	call   80108398 <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 10 02 00 00    	je     80100f37 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2f:	83 ec 08             	sub    $0x8,%esp
80100d32:	50                   	push   %eax
80100d33:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d36:	e8 83 78 00 00       	call   801085be <clearpteu>
80100d3b:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d41:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4b:	e9 96 00 00 00       	jmp    80100de6 <exec+0x275>
    if(argc >= MAXARG)
80100d50:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d54:	0f 87 e0 01 00 00    	ja     80100f3a <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d67:	01 d0                	add    %edx,%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	83 ec 0c             	sub    $0xc,%esp
80100d6e:	50                   	push   %eax
80100d6f:	e8 2b 4a 00 00       	call   8010579f <strlen>
80100d74:	83 c4 10             	add    $0x10,%esp
80100d77:	89 c2                	mov    %eax,%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	29 d0                	sub    %edx,%eax
80100d7e:	83 e8 01             	sub    $0x1,%eax
80100d81:	83 e0 fc             	and    $0xfffffffc,%eax
80100d84:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 fe 49 00 00       	call   8010579f <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	83 c0 01             	add    $0x1,%eax
80100da7:	89 c1                	mov    %eax,%ecx
80100da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db6:	01 d0                	add    %edx,%eax
80100db8:	8b 00                	mov    (%eax),%eax
80100dba:	51                   	push   %ecx
80100dbb:	50                   	push   %eax
80100dbc:	ff 75 dc             	pushl  -0x24(%ebp)
80100dbf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc2:	e8 ae 79 00 00       	call   80108775 <copyout>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	0f 88 6b 01 00 00    	js     80100f3d <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 50 03             	lea    0x3(%eax),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df3:	01 d0                	add    %edx,%eax
80100df5:	8b 00                	mov    (%eax),%eax
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 85 51 ff ff ff    	jne    80100d50 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 03             	add    $0x3,%eax
80100e05:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e10:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e17:	ff ff ff 
  ustack[1] = argc;
80100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 01             	add    $0x1,%eax
80100e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e33:	29 d0                	sub    %edx,%eax
80100e35:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3e:	83 c0 04             	add    $0x4,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 04             	add    $0x4,%eax
80100e4d:	c1 e0 02             	shl    $0x2,%eax
80100e50:	50                   	push   %eax
80100e51:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 12 79 00 00       	call   80108775 <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 d2 00 00 00    	js     80100f40 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e7a:	eb 17                	jmp    80100e93 <exec+0x322>
    if(*s == '/')
80100e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7f:	0f b6 00             	movzbl (%eax),%eax
80100e82:	3c 2f                	cmp    $0x2f,%al
80100e84:	75 09                	jne    80100e8f <exec+0x31e>
      last = s+1;
80100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e89:	83 c0 01             	add    $0x1,%eax
80100e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e96:	0f b6 00             	movzbl (%eax),%eax
80100e99:	84 c0                	test   %al,%al
80100e9b:	75 df                	jne    80100e7c <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	83 c0 6c             	add    $0x6c,%eax
80100ea6:	83 ec 04             	sub    $0x4,%esp
80100ea9:	6a 10                	push   $0x10
80100eab:	ff 75 f0             	pushl  -0x10(%ebp)
80100eae:	50                   	push   %eax
80100eaf:	e8 a1 48 00 00       	call   80105755 <safestrcpy>
80100eb4:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 04             	mov    0x4(%eax),%eax
80100ec0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ecc:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed8:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee0:	8b 40 18             	mov    0x18(%eax),%eax
80100ee3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ee9:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef2:	8b 40 18             	mov    0x18(%eax),%eax
80100ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef8:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f01:	83 ec 0c             	sub    $0xc,%esp
80100f04:	50                   	push   %eax
80100f05:	e8 ce 71 00 00       	call   801080d8 <switchuvm>
80100f0a:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	ff 75 d0             	pushl  -0x30(%ebp)
80100f13:	e8 06 76 00 00       	call   8010851e <freevm>
80100f18:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f1b:	b8 00 00 00 00       	mov    $0x0,%eax
80100f20:	eb 51                	jmp    80100f73 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f22:	90                   	nop
80100f23:	eb 1c                	jmp    80100f41 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f25:	90                   	nop
80100f26:	eb 19                	jmp    80100f41 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f28:	90                   	nop
80100f29:	eb 16                	jmp    80100f41 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f2b:	90                   	nop
80100f2c:	eb 13                	jmp    80100f41 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f2e:	90                   	nop
80100f2f:	eb 10                	jmp    80100f41 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f31:	90                   	nop
80100f32:	eb 0d                	jmp    80100f41 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f34:	90                   	nop
80100f35:	eb 0a                	jmp    80100f41 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f37:	90                   	nop
80100f38:	eb 07                	jmp    80100f41 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f3a:	90                   	nop
80100f3b:	eb 04                	jmp    80100f41 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f3d:	90                   	nop
80100f3e:	eb 01                	jmp    80100f41 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f40:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f41:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f45:	74 0e                	je     80100f55 <exec+0x3e4>
    freevm(pgdir);
80100f47:	83 ec 0c             	sub    $0xc,%esp
80100f4a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f4d:	e8 cc 75 00 00       	call   8010851e <freevm>
80100f52:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f55:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f59:	74 13                	je     80100f6e <exec+0x3fd>
    iunlockput(ip);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 d8             	pushl  -0x28(%ebp)
80100f61:	e8 c4 0c 00 00       	call   80101c2a <iunlockput>
80100f66:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f69:	e8 6b 26 00 00       	call   801035d9 <end_op>
  }
  return -1;
80100f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f73:	c9                   	leave  
80100f74:	c3                   	ret    

80100f75 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f75:	55                   	push   %ebp
80100f76:	89 e5                	mov    %esp,%ebp
80100f78:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f7b:	83 ec 08             	sub    $0x8,%esp
80100f7e:	68 7a 88 10 80       	push   $0x8010887a
80100f83:	68 20 08 11 80       	push   $0x80110820
80100f88:	e8 40 43 00 00       	call   801052cd <initlock>
80100f8d:	83 c4 10             	add    $0x10,%esp
}
80100f90:	90                   	nop
80100f91:	c9                   	leave  
80100f92:	c3                   	ret    

80100f93 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f93:	55                   	push   %ebp
80100f94:	89 e5                	mov    %esp,%ebp
80100f96:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f99:	83 ec 0c             	sub    $0xc,%esp
80100f9c:	68 20 08 11 80       	push   $0x80110820
80100fa1:	e8 49 43 00 00       	call   801052ef <acquire>
80100fa6:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa9:	c7 45 f4 54 08 11 80 	movl   $0x80110854,-0xc(%ebp)
80100fb0:	eb 2d                	jmp    80100fdf <filealloc+0x4c>
    if(f->ref == 0){
80100fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb5:	8b 40 04             	mov    0x4(%eax),%eax
80100fb8:	85 c0                	test   %eax,%eax
80100fba:	75 1f                	jne    80100fdb <filealloc+0x48>
      f->ref = 1;
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fc6:	83 ec 0c             	sub    $0xc,%esp
80100fc9:	68 20 08 11 80       	push   $0x80110820
80100fce:	e8 83 43 00 00       	call   80105356 <release>
80100fd3:	83 c4 10             	add    $0x10,%esp
      return f;
80100fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd9:	eb 23                	jmp    80100ffe <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fdb:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fdf:	b8 b4 11 11 80       	mov    $0x801111b4,%eax
80100fe4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fe7:	72 c9                	jb     80100fb2 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fe9:	83 ec 0c             	sub    $0xc,%esp
80100fec:	68 20 08 11 80       	push   $0x80110820
80100ff1:	e8 60 43 00 00       	call   80105356 <release>
80100ff6:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ff9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100ffe:	c9                   	leave  
80100fff:	c3                   	ret    

80101000 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101000:	55                   	push   %ebp
80101001:	89 e5                	mov    %esp,%ebp
80101003:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101006:	83 ec 0c             	sub    $0xc,%esp
80101009:	68 20 08 11 80       	push   $0x80110820
8010100e:	e8 dc 42 00 00       	call   801052ef <acquire>
80101013:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	8b 40 04             	mov    0x4(%eax),%eax
8010101c:	85 c0                	test   %eax,%eax
8010101e:	7f 0d                	jg     8010102d <filedup+0x2d>
    panic("filedup");
80101020:	83 ec 0c             	sub    $0xc,%esp
80101023:	68 81 88 10 80       	push   $0x80108881
80101028:	e8 39 f5 ff ff       	call   80100566 <panic>
  f->ref++;
8010102d:	8b 45 08             	mov    0x8(%ebp),%eax
80101030:	8b 40 04             	mov    0x4(%eax),%eax
80101033:	8d 50 01             	lea    0x1(%eax),%edx
80101036:	8b 45 08             	mov    0x8(%ebp),%eax
80101039:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 20 08 11 80       	push   $0x80110820
80101044:	e8 0d 43 00 00       	call   80105356 <release>
80101049:	83 c4 10             	add    $0x10,%esp
  return f;
8010104c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010104f:	c9                   	leave  
80101050:	c3                   	ret    

80101051 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101051:	55                   	push   %ebp
80101052:	89 e5                	mov    %esp,%ebp
80101054:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101057:	83 ec 0c             	sub    $0xc,%esp
8010105a:	68 20 08 11 80       	push   $0x80110820
8010105f:	e8 8b 42 00 00       	call   801052ef <acquire>
80101064:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	8b 40 04             	mov    0x4(%eax),%eax
8010106d:	85 c0                	test   %eax,%eax
8010106f:	7f 0d                	jg     8010107e <fileclose+0x2d>
    panic("fileclose");
80101071:	83 ec 0c             	sub    $0xc,%esp
80101074:	68 89 88 10 80       	push   $0x80108889
80101079:	e8 e8 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010107e:	8b 45 08             	mov    0x8(%ebp),%eax
80101081:	8b 40 04             	mov    0x4(%eax),%eax
80101084:	8d 50 ff             	lea    -0x1(%eax),%edx
80101087:	8b 45 08             	mov    0x8(%ebp),%eax
8010108a:	89 50 04             	mov    %edx,0x4(%eax)
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8b 40 04             	mov    0x4(%eax),%eax
80101093:	85 c0                	test   %eax,%eax
80101095:	7e 15                	jle    801010ac <fileclose+0x5b>
    release(&ftable.lock);
80101097:	83 ec 0c             	sub    $0xc,%esp
8010109a:	68 20 08 11 80       	push   $0x80110820
8010109f:	e8 b2 42 00 00       	call   80105356 <release>
801010a4:	83 c4 10             	add    $0x10,%esp
801010a7:	e9 8b 00 00 00       	jmp    80101137 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010ac:	8b 45 08             	mov    0x8(%ebp),%eax
801010af:	8b 10                	mov    (%eax),%edx
801010b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010b4:	8b 50 04             	mov    0x4(%eax),%edx
801010b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010ba:	8b 50 08             	mov    0x8(%eax),%edx
801010bd:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010c0:	8b 50 0c             	mov    0xc(%eax),%edx
801010c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010c6:	8b 50 10             	mov    0x10(%eax),%edx
801010c9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010cc:	8b 40 14             	mov    0x14(%eax),%eax
801010cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010dc:	8b 45 08             	mov    0x8(%ebp),%eax
801010df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010e5:	83 ec 0c             	sub    $0xc,%esp
801010e8:	68 20 08 11 80       	push   $0x80110820
801010ed:	e8 64 42 00 00       	call   80105356 <release>
801010f2:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010f8:	83 f8 01             	cmp    $0x1,%eax
801010fb:	75 19                	jne    80101116 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010fd:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101101:	0f be d0             	movsbl %al,%edx
80101104:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101107:	83 ec 08             	sub    $0x8,%esp
8010110a:	52                   	push   %edx
8010110b:	50                   	push   %eax
8010110c:	e8 83 30 00 00       	call   80104194 <pipeclose>
80101111:	83 c4 10             	add    $0x10,%esp
80101114:	eb 21                	jmp    80101137 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101116:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101119:	83 f8 02             	cmp    $0x2,%eax
8010111c:	75 19                	jne    80101137 <fileclose+0xe6>
    begin_op();
8010111e:	e8 2a 24 00 00       	call   8010354d <begin_op>
    iput(ff.ip);
80101123:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101126:	83 ec 0c             	sub    $0xc,%esp
80101129:	50                   	push   %eax
8010112a:	e8 0b 0a 00 00       	call   80101b3a <iput>
8010112f:	83 c4 10             	add    $0x10,%esp
    end_op();
80101132:	e8 a2 24 00 00       	call   801035d9 <end_op>
  }
}
80101137:	c9                   	leave  
80101138:	c3                   	ret    

80101139 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101139:	55                   	push   %ebp
8010113a:	89 e5                	mov    %esp,%ebp
8010113c:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010113f:	8b 45 08             	mov    0x8(%ebp),%eax
80101142:	8b 00                	mov    (%eax),%eax
80101144:	83 f8 02             	cmp    $0x2,%eax
80101147:	75 40                	jne    80101189 <filestat+0x50>
    ilock(f->ip);
80101149:	8b 45 08             	mov    0x8(%ebp),%eax
8010114c:	8b 40 10             	mov    0x10(%eax),%eax
8010114f:	83 ec 0c             	sub    $0xc,%esp
80101152:	50                   	push   %eax
80101153:	e8 12 08 00 00       	call   8010196a <ilock>
80101158:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010115b:	8b 45 08             	mov    0x8(%ebp),%eax
8010115e:	8b 40 10             	mov    0x10(%eax),%eax
80101161:	83 ec 08             	sub    $0x8,%esp
80101164:	ff 75 0c             	pushl  0xc(%ebp)
80101167:	50                   	push   %eax
80101168:	e8 25 0d 00 00       	call   80101e92 <stati>
8010116d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 40 10             	mov    0x10(%eax),%eax
80101176:	83 ec 0c             	sub    $0xc,%esp
80101179:	50                   	push   %eax
8010117a:	e8 49 09 00 00       	call   80101ac8 <iunlock>
8010117f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101182:	b8 00 00 00 00       	mov    $0x0,%eax
80101187:	eb 05                	jmp    8010118e <filestat+0x55>
  }
  return -1;
80101189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010118e:	c9                   	leave  
8010118f:	c3                   	ret    

80101190 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101190:	55                   	push   %ebp
80101191:	89 e5                	mov    %esp,%ebp
80101193:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010119d:	84 c0                	test   %al,%al
8010119f:	75 0a                	jne    801011ab <fileread+0x1b>
    return -1;
801011a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011a6:	e9 9b 00 00 00       	jmp    80101246 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ab:	8b 45 08             	mov    0x8(%ebp),%eax
801011ae:	8b 00                	mov    (%eax),%eax
801011b0:	83 f8 01             	cmp    $0x1,%eax
801011b3:	75 1a                	jne    801011cf <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 40 0c             	mov    0xc(%eax),%eax
801011bb:	83 ec 04             	sub    $0x4,%esp
801011be:	ff 75 10             	pushl  0x10(%ebp)
801011c1:	ff 75 0c             	pushl  0xc(%ebp)
801011c4:	50                   	push   %eax
801011c5:	e8 72 31 00 00       	call   8010433c <piperead>
801011ca:	83 c4 10             	add    $0x10,%esp
801011cd:	eb 77                	jmp    80101246 <fileread+0xb6>
  if(f->type == FD_INODE){
801011cf:	8b 45 08             	mov    0x8(%ebp),%eax
801011d2:	8b 00                	mov    (%eax),%eax
801011d4:	83 f8 02             	cmp    $0x2,%eax
801011d7:	75 60                	jne    80101239 <fileread+0xa9>
    ilock(f->ip);
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 10             	mov    0x10(%eax),%eax
801011df:	83 ec 0c             	sub    $0xc,%esp
801011e2:	50                   	push   %eax
801011e3:	e8 82 07 00 00       	call   8010196a <ilock>
801011e8:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	8b 50 14             	mov    0x14(%eax),%edx
801011f4:	8b 45 08             	mov    0x8(%ebp),%eax
801011f7:	8b 40 10             	mov    0x10(%eax),%eax
801011fa:	51                   	push   %ecx
801011fb:	52                   	push   %edx
801011fc:	ff 75 0c             	pushl  0xc(%ebp)
801011ff:	50                   	push   %eax
80101200:	e8 d3 0c 00 00       	call   80101ed8 <readi>
80101205:	83 c4 10             	add    $0x10,%esp
80101208:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010120b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010120f:	7e 11                	jle    80101222 <fileread+0x92>
      f->off += r;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 50 14             	mov    0x14(%eax),%edx
80101217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121a:	01 c2                	add    %eax,%edx
8010121c:	8b 45 08             	mov    0x8(%ebp),%eax
8010121f:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101222:	8b 45 08             	mov    0x8(%ebp),%eax
80101225:	8b 40 10             	mov    0x10(%eax),%eax
80101228:	83 ec 0c             	sub    $0xc,%esp
8010122b:	50                   	push   %eax
8010122c:	e8 97 08 00 00       	call   80101ac8 <iunlock>
80101231:	83 c4 10             	add    $0x10,%esp
    return r;
80101234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101237:	eb 0d                	jmp    80101246 <fileread+0xb6>
  }
  panic("fileread");
80101239:	83 ec 0c             	sub    $0xc,%esp
8010123c:	68 93 88 10 80       	push   $0x80108893
80101241:	e8 20 f3 ff ff       	call   80100566 <panic>
}
80101246:	c9                   	leave  
80101247:	c3                   	ret    

80101248 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101248:	55                   	push   %ebp
80101249:	89 e5                	mov    %esp,%ebp
8010124b:	53                   	push   %ebx
8010124c:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101256:	84 c0                	test   %al,%al
80101258:	75 0a                	jne    80101264 <filewrite+0x1c>
    return -1;
8010125a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010125f:	e9 1b 01 00 00       	jmp    8010137f <filewrite+0x137>
  if(f->type == FD_PIPE)
80101264:	8b 45 08             	mov    0x8(%ebp),%eax
80101267:	8b 00                	mov    (%eax),%eax
80101269:	83 f8 01             	cmp    $0x1,%eax
8010126c:	75 1d                	jne    8010128b <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 40 0c             	mov    0xc(%eax),%eax
80101274:	83 ec 04             	sub    $0x4,%esp
80101277:	ff 75 10             	pushl  0x10(%ebp)
8010127a:	ff 75 0c             	pushl  0xc(%ebp)
8010127d:	50                   	push   %eax
8010127e:	e8 bb 2f 00 00       	call   8010423e <pipewrite>
80101283:	83 c4 10             	add    $0x10,%esp
80101286:	e9 f4 00 00 00       	jmp    8010137f <filewrite+0x137>
  if(f->type == FD_INODE){
8010128b:	8b 45 08             	mov    0x8(%ebp),%eax
8010128e:	8b 00                	mov    (%eax),%eax
80101290:	83 f8 02             	cmp    $0x2,%eax
80101293:	0f 85 d9 00 00 00    	jne    80101372 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101299:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012a7:	e9 a3 00 00 00       	jmp    8010134f <filewrite+0x107>
      int n1 = n - i;
801012ac:	8b 45 10             	mov    0x10(%ebp),%eax
801012af:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012b8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012bb:	7e 06                	jle    801012c3 <filewrite+0x7b>
        n1 = max;
801012bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012c0:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012c3:	e8 85 22 00 00       	call   8010354d <begin_op>
      ilock(f->ip);
801012c8:	8b 45 08             	mov    0x8(%ebp),%eax
801012cb:	8b 40 10             	mov    0x10(%eax),%eax
801012ce:	83 ec 0c             	sub    $0xc,%esp
801012d1:	50                   	push   %eax
801012d2:	e8 93 06 00 00       	call   8010196a <ilock>
801012d7:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012da:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012dd:	8b 45 08             	mov    0x8(%ebp),%eax
801012e0:	8b 50 14             	mov    0x14(%eax),%edx
801012e3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801012e9:	01 c3                	add    %eax,%ebx
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 40 10             	mov    0x10(%eax),%eax
801012f1:	51                   	push   %ecx
801012f2:	52                   	push   %edx
801012f3:	53                   	push   %ebx
801012f4:	50                   	push   %eax
801012f5:	e8 35 0d 00 00       	call   8010202f <writei>
801012fa:	83 c4 10             	add    $0x10,%esp
801012fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101300:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101304:	7e 11                	jle    80101317 <filewrite+0xcf>
        f->off += r;
80101306:	8b 45 08             	mov    0x8(%ebp),%eax
80101309:	8b 50 14             	mov    0x14(%eax),%edx
8010130c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010130f:	01 c2                	add    %eax,%edx
80101311:	8b 45 08             	mov    0x8(%ebp),%eax
80101314:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101317:	8b 45 08             	mov    0x8(%ebp),%eax
8010131a:	8b 40 10             	mov    0x10(%eax),%eax
8010131d:	83 ec 0c             	sub    $0xc,%esp
80101320:	50                   	push   %eax
80101321:	e8 a2 07 00 00       	call   80101ac8 <iunlock>
80101326:	83 c4 10             	add    $0x10,%esp
      end_op();
80101329:	e8 ab 22 00 00       	call   801035d9 <end_op>

      if(r < 0)
8010132e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101332:	78 29                	js     8010135d <filewrite+0x115>
        break;
      if(r != n1)
80101334:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101337:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010133a:	74 0d                	je     80101349 <filewrite+0x101>
        panic("short filewrite");
8010133c:	83 ec 0c             	sub    $0xc,%esp
8010133f:	68 9c 88 10 80       	push   $0x8010889c
80101344:	e8 1d f2 ff ff       	call   80100566 <panic>
      i += r;
80101349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134c:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101352:	3b 45 10             	cmp    0x10(%ebp),%eax
80101355:	0f 8c 51 ff ff ff    	jl     801012ac <filewrite+0x64>
8010135b:	eb 01                	jmp    8010135e <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010135d:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010135e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101361:	3b 45 10             	cmp    0x10(%ebp),%eax
80101364:	75 05                	jne    8010136b <filewrite+0x123>
80101366:	8b 45 10             	mov    0x10(%ebp),%eax
80101369:	eb 14                	jmp    8010137f <filewrite+0x137>
8010136b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101370:	eb 0d                	jmp    8010137f <filewrite+0x137>
  }
  panic("filewrite");
80101372:	83 ec 0c             	sub    $0xc,%esp
80101375:	68 ac 88 10 80       	push   $0x801088ac
8010137a:	e8 e7 f1 ff ff       	call   80100566 <panic>
}
8010137f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101382:	c9                   	leave  
80101383:	c3                   	ret    

80101384 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101384:	55                   	push   %ebp
80101385:	89 e5                	mov    %esp,%ebp
80101387:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010138a:	8b 45 08             	mov    0x8(%ebp),%eax
8010138d:	83 ec 08             	sub    $0x8,%esp
80101390:	6a 01                	push   $0x1
80101392:	50                   	push   %eax
80101393:	e8 1e ee ff ff       	call   801001b6 <bread>
80101398:	83 c4 10             	add    $0x10,%esp
8010139b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a1:	83 c0 18             	add    $0x18,%eax
801013a4:	83 ec 04             	sub    $0x4,%esp
801013a7:	6a 1c                	push   $0x1c
801013a9:	50                   	push   %eax
801013aa:	ff 75 0c             	pushl  0xc(%ebp)
801013ad:	e8 5f 42 00 00       	call   80105611 <memmove>
801013b2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013b5:	83 ec 0c             	sub    $0xc,%esp
801013b8:	ff 75 f4             	pushl  -0xc(%ebp)
801013bb:	e8 6e ee ff ff       	call   8010022e <brelse>
801013c0:	83 c4 10             	add    $0x10,%esp
}
801013c3:	90                   	nop
801013c4:	c9                   	leave  
801013c5:	c3                   	ret    

801013c6 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013c6:	55                   	push   %ebp
801013c7:	89 e5                	mov    %esp,%ebp
801013c9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	83 ec 08             	sub    $0x8,%esp
801013d5:	52                   	push   %edx
801013d6:	50                   	push   %eax
801013d7:	e8 da ed ff ff       	call   801001b6 <bread>
801013dc:	83 c4 10             	add    $0x10,%esp
801013df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e5:	83 c0 18             	add    $0x18,%eax
801013e8:	83 ec 04             	sub    $0x4,%esp
801013eb:	68 00 02 00 00       	push   $0x200
801013f0:	6a 00                	push   $0x0
801013f2:	50                   	push   %eax
801013f3:	e8 5a 41 00 00       	call   80105552 <memset>
801013f8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013fb:	83 ec 0c             	sub    $0xc,%esp
801013fe:	ff 75 f4             	pushl  -0xc(%ebp)
80101401:	e8 7f 23 00 00       	call   80103785 <log_write>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	pushl  -0xc(%ebp)
8010140f:	e8 1a ee ff ff       	call   8010022e <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave  
80101419:	c3                   	ret    

8010141a <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101420:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101427:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010142e:	e9 13 01 00 00       	jmp    80101546 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101436:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010143c:	85 c0                	test   %eax,%eax
8010143e:	0f 48 c2             	cmovs  %edx,%eax
80101441:	c1 f8 0c             	sar    $0xc,%eax
80101444:	89 c2                	mov    %eax,%edx
80101446:	a1 38 12 11 80       	mov    0x80111238,%eax
8010144b:	01 d0                	add    %edx,%eax
8010144d:	83 ec 08             	sub    $0x8,%esp
80101450:	50                   	push   %eax
80101451:	ff 75 08             	pushl  0x8(%ebp)
80101454:	e8 5d ed ff ff       	call   801001b6 <bread>
80101459:	83 c4 10             	add    $0x10,%esp
8010145c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010145f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101466:	e9 a6 00 00 00       	jmp    80101511 <balloc+0xf7>
      m = 1 << (bi % 8);
8010146b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146e:	99                   	cltd   
8010146f:	c1 ea 1d             	shr    $0x1d,%edx
80101472:	01 d0                	add    %edx,%eax
80101474:	83 e0 07             	and    $0x7,%eax
80101477:	29 d0                	sub    %edx,%eax
80101479:	ba 01 00 00 00       	mov    $0x1,%edx
8010147e:	89 c1                	mov    %eax,%ecx
80101480:	d3 e2                	shl    %cl,%edx
80101482:	89 d0                	mov    %edx,%eax
80101484:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148a:	8d 50 07             	lea    0x7(%eax),%edx
8010148d:	85 c0                	test   %eax,%eax
8010148f:	0f 48 c2             	cmovs  %edx,%eax
80101492:	c1 f8 03             	sar    $0x3,%eax
80101495:	89 c2                	mov    %eax,%edx
80101497:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149a:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010149f:	0f b6 c0             	movzbl %al,%eax
801014a2:	23 45 e8             	and    -0x18(%ebp),%eax
801014a5:	85 c0                	test   %eax,%eax
801014a7:	75 64                	jne    8010150d <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ac:	8d 50 07             	lea    0x7(%eax),%edx
801014af:	85 c0                	test   %eax,%eax
801014b1:	0f 48 c2             	cmovs  %edx,%eax
801014b4:	c1 f8 03             	sar    $0x3,%eax
801014b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ba:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014bf:	89 d1                	mov    %edx,%ecx
801014c1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014c4:	09 ca                	or     %ecx,%edx
801014c6:	89 d1                	mov    %edx,%ecx
801014c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014cb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014cf:	83 ec 0c             	sub    $0xc,%esp
801014d2:	ff 75 ec             	pushl  -0x14(%ebp)
801014d5:	e8 ab 22 00 00       	call   80103785 <log_write>
801014da:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014dd:	83 ec 0c             	sub    $0xc,%esp
801014e0:	ff 75 ec             	pushl  -0x14(%ebp)
801014e3:	e8 46 ed ff ff       	call   8010022e <brelse>
801014e8:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f1:	01 c2                	add    %eax,%edx
801014f3:	8b 45 08             	mov    0x8(%ebp),%eax
801014f6:	83 ec 08             	sub    $0x8,%esp
801014f9:	52                   	push   %edx
801014fa:	50                   	push   %eax
801014fb:	e8 c6 fe ff ff       	call   801013c6 <bzero>
80101500:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101503:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101509:	01 d0                	add    %edx,%eax
8010150b:	eb 57                	jmp    80101564 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010150d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101511:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101518:	7f 17                	jg     80101531 <balloc+0x117>
8010151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101520:	01 d0                	add    %edx,%eax
80101522:	89 c2                	mov    %eax,%edx
80101524:	a1 20 12 11 80       	mov    0x80111220,%eax
80101529:	39 c2                	cmp    %eax,%edx
8010152b:	0f 82 3a ff ff ff    	jb     8010146b <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101531:	83 ec 0c             	sub    $0xc,%esp
80101534:	ff 75 ec             	pushl  -0x14(%ebp)
80101537:	e8 f2 ec ff ff       	call   8010022e <brelse>
8010153c:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010153f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101546:	8b 15 20 12 11 80    	mov    0x80111220,%edx
8010154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154f:	39 c2                	cmp    %eax,%edx
80101551:	0f 87 dc fe ff ff    	ja     80101433 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101557:	83 ec 0c             	sub    $0xc,%esp
8010155a:	68 b8 88 10 80       	push   $0x801088b8
8010155f:	e8 02 f0 ff ff       	call   80100566 <panic>
}
80101564:	c9                   	leave  
80101565:	c3                   	ret    

80101566 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101566:	55                   	push   %ebp
80101567:	89 e5                	mov    %esp,%ebp
80101569:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010156c:	83 ec 08             	sub    $0x8,%esp
8010156f:	68 20 12 11 80       	push   $0x80111220
80101574:	ff 75 08             	pushl  0x8(%ebp)
80101577:	e8 08 fe ff ff       	call   80101384 <readsb>
8010157c:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010157f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101582:	c1 e8 0c             	shr    $0xc,%eax
80101585:	89 c2                	mov    %eax,%edx
80101587:	a1 38 12 11 80       	mov    0x80111238,%eax
8010158c:	01 c2                	add    %eax,%edx
8010158e:	8b 45 08             	mov    0x8(%ebp),%eax
80101591:	83 ec 08             	sub    $0x8,%esp
80101594:	52                   	push   %edx
80101595:	50                   	push   %eax
80101596:	e8 1b ec ff ff       	call   801001b6 <bread>
8010159b:	83 c4 10             	add    $0x10,%esp
8010159e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a4:	25 ff 0f 00 00       	and    $0xfff,%eax
801015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015af:	99                   	cltd   
801015b0:	c1 ea 1d             	shr    $0x1d,%edx
801015b3:	01 d0                	add    %edx,%eax
801015b5:	83 e0 07             	and    $0x7,%eax
801015b8:	29 d0                	sub    %edx,%eax
801015ba:	ba 01 00 00 00       	mov    $0x1,%edx
801015bf:	89 c1                	mov    %eax,%ecx
801015c1:	d3 e2                	shl    %cl,%edx
801015c3:	89 d0                	mov    %edx,%eax
801015c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cb:	8d 50 07             	lea    0x7(%eax),%edx
801015ce:	85 c0                	test   %eax,%eax
801015d0:	0f 48 c2             	cmovs  %edx,%eax
801015d3:	c1 f8 03             	sar    $0x3,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015db:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015e0:	0f b6 c0             	movzbl %al,%eax
801015e3:	23 45 ec             	and    -0x14(%ebp),%eax
801015e6:	85 c0                	test   %eax,%eax
801015e8:	75 0d                	jne    801015f7 <bfree+0x91>
    panic("freeing free block");
801015ea:	83 ec 0c             	sub    $0xc,%esp
801015ed:	68 ce 88 10 80       	push   $0x801088ce
801015f2:	e8 6f ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	8d 50 07             	lea    0x7(%eax),%edx
801015fd:	85 c0                	test   %eax,%eax
801015ff:	0f 48 c2             	cmovs  %edx,%eax
80101602:	c1 f8 03             	sar    $0x3,%eax
80101605:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101608:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010160d:	89 d1                	mov    %edx,%ecx
8010160f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101612:	f7 d2                	not    %edx
80101614:	21 ca                	and    %ecx,%edx
80101616:	89 d1                	mov    %edx,%ecx
80101618:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010161f:	83 ec 0c             	sub    $0xc,%esp
80101622:	ff 75 f4             	pushl  -0xc(%ebp)
80101625:	e8 5b 21 00 00       	call   80103785 <log_write>
8010162a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	ff 75 f4             	pushl  -0xc(%ebp)
80101633:	e8 f6 eb ff ff       	call   8010022e <brelse>
80101638:	83 c4 10             	add    $0x10,%esp
}
8010163b:	90                   	nop
8010163c:	c9                   	leave  
8010163d:	c3                   	ret    

8010163e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010163e:	55                   	push   %ebp
8010163f:	89 e5                	mov    %esp,%ebp
80101641:	57                   	push   %edi
80101642:	56                   	push   %esi
80101643:	53                   	push   %ebx
80101644:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101647:	83 ec 08             	sub    $0x8,%esp
8010164a:	68 e1 88 10 80       	push   $0x801088e1
8010164f:	68 40 12 11 80       	push   $0x80111240
80101654:	e8 74 3c 00 00       	call   801052cd <initlock>
80101659:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010165c:	83 ec 08             	sub    $0x8,%esp
8010165f:	68 20 12 11 80       	push   $0x80111220
80101664:	ff 75 08             	pushl  0x8(%ebp)
80101667:	e8 18 fd ff ff       	call   80101384 <readsb>
8010166c:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010166f:	a1 38 12 11 80       	mov    0x80111238,%eax
80101674:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101677:	8b 3d 34 12 11 80    	mov    0x80111234,%edi
8010167d:	8b 35 30 12 11 80    	mov    0x80111230,%esi
80101683:	8b 1d 2c 12 11 80    	mov    0x8011122c,%ebx
80101689:	8b 0d 28 12 11 80    	mov    0x80111228,%ecx
8010168f:	8b 15 24 12 11 80    	mov    0x80111224,%edx
80101695:	a1 20 12 11 80       	mov    0x80111220,%eax
8010169a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010169d:	57                   	push   %edi
8010169e:	56                   	push   %esi
8010169f:	53                   	push   %ebx
801016a0:	51                   	push   %ecx
801016a1:	52                   	push   %edx
801016a2:	50                   	push   %eax
801016a3:	68 e8 88 10 80       	push   $0x801088e8
801016a8:	e8 19 ed ff ff       	call   801003c6 <cprintf>
801016ad:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016b0:	90                   	nop
801016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016b4:	5b                   	pop    %ebx
801016b5:	5e                   	pop    %esi
801016b6:	5f                   	pop    %edi
801016b7:	5d                   	pop    %ebp
801016b8:	c3                   	ret    

801016b9 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016b9:	55                   	push   %ebp
801016ba:	89 e5                	mov    %esp,%ebp
801016bc:	83 ec 28             	sub    $0x28,%esp
801016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c2:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016c6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016cd:	e9 9e 00 00 00       	jmp    80101770 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d5:	c1 e8 03             	shr    $0x3,%eax
801016d8:	89 c2                	mov    %eax,%edx
801016da:	a1 34 12 11 80       	mov    0x80111234,%eax
801016df:	01 d0                	add    %edx,%eax
801016e1:	83 ec 08             	sub    $0x8,%esp
801016e4:	50                   	push   %eax
801016e5:	ff 75 08             	pushl  0x8(%ebp)
801016e8:	e8 c9 ea ff ff       	call   801001b6 <bread>
801016ed:	83 c4 10             	add    $0x10,%esp
801016f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f6:	8d 50 18             	lea    0x18(%eax),%edx
801016f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016fc:	83 e0 07             	and    $0x7,%eax
801016ff:	c1 e0 06             	shl    $0x6,%eax
80101702:	01 d0                	add    %edx,%eax
80101704:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101707:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010170a:	0f b7 00             	movzwl (%eax),%eax
8010170d:	66 85 c0             	test   %ax,%ax
80101710:	75 4c                	jne    8010175e <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101712:	83 ec 04             	sub    $0x4,%esp
80101715:	6a 40                	push   $0x40
80101717:	6a 00                	push   $0x0
80101719:	ff 75 ec             	pushl  -0x14(%ebp)
8010171c:	e8 31 3e 00 00       	call   80105552 <memset>
80101721:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101724:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101727:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010172b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010172e:	83 ec 0c             	sub    $0xc,%esp
80101731:	ff 75 f0             	pushl  -0x10(%ebp)
80101734:	e8 4c 20 00 00       	call   80103785 <log_write>
80101739:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010173c:	83 ec 0c             	sub    $0xc,%esp
8010173f:	ff 75 f0             	pushl  -0x10(%ebp)
80101742:	e8 e7 ea ff ff       	call   8010022e <brelse>
80101747:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	83 ec 08             	sub    $0x8,%esp
80101750:	50                   	push   %eax
80101751:	ff 75 08             	pushl  0x8(%ebp)
80101754:	e8 f8 00 00 00       	call   80101851 <iget>
80101759:	83 c4 10             	add    $0x10,%esp
8010175c:	eb 30                	jmp    8010178e <ialloc+0xd5>
    }
    brelse(bp);
8010175e:	83 ec 0c             	sub    $0xc,%esp
80101761:	ff 75 f0             	pushl  -0x10(%ebp)
80101764:	e8 c5 ea ff ff       	call   8010022e <brelse>
80101769:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010176c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101770:	8b 15 28 12 11 80    	mov    0x80111228,%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	39 c2                	cmp    %eax,%edx
8010177b:	0f 87 51 ff ff ff    	ja     801016d2 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101781:	83 ec 0c             	sub    $0xc,%esp
80101784:	68 3b 89 10 80       	push   $0x8010893b
80101789:	e8 d8 ed ff ff       	call   80100566 <panic>
}
8010178e:	c9                   	leave  
8010178f:	c3                   	ret    

80101790 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101796:	8b 45 08             	mov    0x8(%ebp),%eax
80101799:	8b 40 04             	mov    0x4(%eax),%eax
8010179c:	c1 e8 03             	shr    $0x3,%eax
8010179f:	89 c2                	mov    %eax,%edx
801017a1:	a1 34 12 11 80       	mov    0x80111234,%eax
801017a6:	01 c2                	add    %eax,%edx
801017a8:	8b 45 08             	mov    0x8(%ebp),%eax
801017ab:	8b 00                	mov    (%eax),%eax
801017ad:	83 ec 08             	sub    $0x8,%esp
801017b0:	52                   	push   %edx
801017b1:	50                   	push   %eax
801017b2:	e8 ff e9 ff ff       	call   801001b6 <bread>
801017b7:	83 c4 10             	add    $0x10,%esp
801017ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c0:	8d 50 18             	lea    0x18(%eax),%edx
801017c3:	8b 45 08             	mov    0x8(%ebp),%eax
801017c6:	8b 40 04             	mov    0x4(%eax),%eax
801017c9:	83 e0 07             	and    $0x7,%eax
801017cc:	c1 e0 06             	shl    $0x6,%eax
801017cf:	01 d0                	add    %edx,%eax
801017d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017d4:	8b 45 08             	mov    0x8(%ebp),%eax
801017d7:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017de:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017e1:	8b 45 08             	mov    0x8(%ebp),%eax
801017e4:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017eb:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017ef:	8b 45 08             	mov    0x8(%ebp),%eax
801017f2:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101800:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101807:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010180b:	8b 45 08             	mov    0x8(%ebp),%eax
8010180e:	8b 50 18             	mov    0x18(%eax),%edx
80101811:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101814:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101817:	8b 45 08             	mov    0x8(%ebp),%eax
8010181a:	8d 50 1c             	lea    0x1c(%eax),%edx
8010181d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101820:	83 c0 0c             	add    $0xc,%eax
80101823:	83 ec 04             	sub    $0x4,%esp
80101826:	6a 34                	push   $0x34
80101828:	52                   	push   %edx
80101829:	50                   	push   %eax
8010182a:	e8 e2 3d 00 00       	call   80105611 <memmove>
8010182f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101832:	83 ec 0c             	sub    $0xc,%esp
80101835:	ff 75 f4             	pushl  -0xc(%ebp)
80101838:	e8 48 1f 00 00       	call   80103785 <log_write>
8010183d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101840:	83 ec 0c             	sub    $0xc,%esp
80101843:	ff 75 f4             	pushl  -0xc(%ebp)
80101846:	e8 e3 e9 ff ff       	call   8010022e <brelse>
8010184b:	83 c4 10             	add    $0x10,%esp
}
8010184e:	90                   	nop
8010184f:	c9                   	leave  
80101850:	c3                   	ret    

80101851 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101851:	55                   	push   %ebp
80101852:	89 e5                	mov    %esp,%ebp
80101854:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101857:	83 ec 0c             	sub    $0xc,%esp
8010185a:	68 40 12 11 80       	push   $0x80111240
8010185f:	e8 8b 3a 00 00       	call   801052ef <acquire>
80101864:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101867:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010186e:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101875:	eb 5d                	jmp    801018d4 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187a:	8b 40 08             	mov    0x8(%eax),%eax
8010187d:	85 c0                	test   %eax,%eax
8010187f:	7e 39                	jle    801018ba <iget+0x69>
80101881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101884:	8b 00                	mov    (%eax),%eax
80101886:	3b 45 08             	cmp    0x8(%ebp),%eax
80101889:	75 2f                	jne    801018ba <iget+0x69>
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	8b 40 04             	mov    0x4(%eax),%eax
80101891:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101894:	75 24                	jne    801018ba <iget+0x69>
      ip->ref++;
80101896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101899:	8b 40 08             	mov    0x8(%eax),%eax
8010189c:	8d 50 01             	lea    0x1(%eax),%edx
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018a5:	83 ec 0c             	sub    $0xc,%esp
801018a8:	68 40 12 11 80       	push   $0x80111240
801018ad:	e8 a4 3a 00 00       	call   80105356 <release>
801018b2:	83 c4 10             	add    $0x10,%esp
      return ip;
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	eb 74                	jmp    8010192e <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018be:	75 10                	jne    801018d0 <iget+0x7f>
801018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c3:	8b 40 08             	mov    0x8(%eax),%eax
801018c6:	85 c0                	test   %eax,%eax
801018c8:	75 06                	jne    801018d0 <iget+0x7f>
      empty = ip;
801018ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d0:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018d4:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801018db:	72 9a                	jb     80101877 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e1:	75 0d                	jne    801018f0 <iget+0x9f>
    panic("iget: no inodes");
801018e3:	83 ec 0c             	sub    $0xc,%esp
801018e6:	68 4d 89 10 80       	push   $0x8010894d
801018eb:	e8 76 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f9:	8b 55 08             	mov    0x8(%ebp),%edx
801018fc:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 55 0c             	mov    0xc(%ebp),%edx
80101904:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101914:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010191b:	83 ec 0c             	sub    $0xc,%esp
8010191e:	68 40 12 11 80       	push   $0x80111240
80101923:	e8 2e 3a 00 00       	call   80105356 <release>
80101928:	83 c4 10             	add    $0x10,%esp

  return ip;
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010192e:	c9                   	leave  
8010192f:	c3                   	ret    

80101930 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101930:	55                   	push   %ebp
80101931:	89 e5                	mov    %esp,%ebp
80101933:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101936:	83 ec 0c             	sub    $0xc,%esp
80101939:	68 40 12 11 80       	push   $0x80111240
8010193e:	e8 ac 39 00 00       	call   801052ef <acquire>
80101943:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101946:	8b 45 08             	mov    0x8(%ebp),%eax
80101949:	8b 40 08             	mov    0x8(%eax),%eax
8010194c:	8d 50 01             	lea    0x1(%eax),%edx
8010194f:	8b 45 08             	mov    0x8(%ebp),%eax
80101952:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101955:	83 ec 0c             	sub    $0xc,%esp
80101958:	68 40 12 11 80       	push   $0x80111240
8010195d:	e8 f4 39 00 00       	call   80105356 <release>
80101962:	83 c4 10             	add    $0x10,%esp
  return ip;
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101968:	c9                   	leave  
80101969:	c3                   	ret    

8010196a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010196a:	55                   	push   %ebp
8010196b:	89 e5                	mov    %esp,%ebp
8010196d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101970:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101974:	74 0a                	je     80101980 <ilock+0x16>
80101976:	8b 45 08             	mov    0x8(%ebp),%eax
80101979:	8b 40 08             	mov    0x8(%eax),%eax
8010197c:	85 c0                	test   %eax,%eax
8010197e:	7f 0d                	jg     8010198d <ilock+0x23>
    panic("ilock");
80101980:	83 ec 0c             	sub    $0xc,%esp
80101983:	68 5d 89 10 80       	push   $0x8010895d
80101988:	e8 d9 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010198d:	83 ec 0c             	sub    $0xc,%esp
80101990:	68 40 12 11 80       	push   $0x80111240
80101995:	e8 55 39 00 00       	call   801052ef <acquire>
8010199a:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010199d:	eb 13                	jmp    801019b2 <ilock+0x48>
    sleep(ip, &icache.lock);
8010199f:	83 ec 08             	sub    $0x8,%esp
801019a2:	68 40 12 11 80       	push   $0x80111240
801019a7:	ff 75 08             	pushl  0x8(%ebp)
801019aa:	e8 3e 36 00 00       	call   80104fed <sleep>
801019af:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019b2:	8b 45 08             	mov    0x8(%ebp),%eax
801019b5:	8b 40 0c             	mov    0xc(%eax),%eax
801019b8:	83 e0 01             	and    $0x1,%eax
801019bb:	85 c0                	test   %eax,%eax
801019bd:	75 e0                	jne    8010199f <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019bf:	8b 45 08             	mov    0x8(%ebp),%eax
801019c2:	8b 40 0c             	mov    0xc(%eax),%eax
801019c5:	83 c8 01             	or     $0x1,%eax
801019c8:	89 c2                	mov    %eax,%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019d0:	83 ec 0c             	sub    $0xc,%esp
801019d3:	68 40 12 11 80       	push   $0x80111240
801019d8:	e8 79 39 00 00       	call   80105356 <release>
801019dd:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	8b 40 0c             	mov    0xc(%eax),%eax
801019e6:	83 e0 02             	and    $0x2,%eax
801019e9:	85 c0                	test   %eax,%eax
801019eb:	0f 85 d4 00 00 00    	jne    80101ac5 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 40 04             	mov    0x4(%eax),%eax
801019f7:	c1 e8 03             	shr    $0x3,%eax
801019fa:	89 c2                	mov    %eax,%edx
801019fc:	a1 34 12 11 80       	mov    0x80111234,%eax
80101a01:	01 c2                	add    %eax,%edx
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	8b 00                	mov    (%eax),%eax
80101a08:	83 ec 08             	sub    $0x8,%esp
80101a0b:	52                   	push   %edx
80101a0c:	50                   	push   %eax
80101a0d:	e8 a4 e7 ff ff       	call   801001b6 <bread>
80101a12:	83 c4 10             	add    $0x10,%esp
80101a15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	8d 50 18             	lea    0x18(%eax),%edx
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	8b 40 04             	mov    0x4(%eax),%eax
80101a24:	83 e0 07             	and    $0x7,%eax
80101a27:	c1 e0 06             	shl    $0x6,%eax
80101a2a:	01 d0                	add    %edx,%eax
80101a2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a32:	0f b7 10             	movzwl (%eax),%edx
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a43:	8b 45 08             	mov    0x8(%ebp),%eax
80101a46:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a62:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a69:	8b 50 08             	mov    0x8(%eax),%edx
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a75:	8d 50 0c             	lea    0xc(%eax),%edx
80101a78:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7b:	83 c0 1c             	add    $0x1c,%eax
80101a7e:	83 ec 04             	sub    $0x4,%esp
80101a81:	6a 34                	push   $0x34
80101a83:	52                   	push   %edx
80101a84:	50                   	push   %eax
80101a85:	e8 87 3b 00 00       	call   80105611 <memmove>
80101a8a:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a8d:	83 ec 0c             	sub    $0xc,%esp
80101a90:	ff 75 f4             	pushl  -0xc(%ebp)
80101a93:	e8 96 e7 ff ff       	call   8010022e <brelse>
80101a98:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa1:	83 c8 02             	or     $0x2,%eax
80101aa4:	89 c2                	mov    %eax,%edx
80101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa9:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101aac:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab3:	66 85 c0             	test   %ax,%ax
80101ab6:	75 0d                	jne    80101ac5 <ilock+0x15b>
      panic("ilock: no type");
80101ab8:	83 ec 0c             	sub    $0xc,%esp
80101abb:	68 63 89 10 80       	push   $0x80108963
80101ac0:	e8 a1 ea ff ff       	call   80100566 <panic>
  }
}
80101ac5:	90                   	nop
80101ac6:	c9                   	leave  
80101ac7:	c3                   	ret    

80101ac8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac8:	55                   	push   %ebp
80101ac9:	89 e5                	mov    %esp,%ebp
80101acb:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ace:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ad2:	74 17                	je     80101aeb <iunlock+0x23>
80101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad7:	8b 40 0c             	mov    0xc(%eax),%eax
80101ada:	83 e0 01             	and    $0x1,%eax
80101add:	85 c0                	test   %eax,%eax
80101adf:	74 0a                	je     80101aeb <iunlock+0x23>
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	8b 40 08             	mov    0x8(%eax),%eax
80101ae7:	85 c0                	test   %eax,%eax
80101ae9:	7f 0d                	jg     80101af8 <iunlock+0x30>
    panic("iunlock");
80101aeb:	83 ec 0c             	sub    $0xc,%esp
80101aee:	68 72 89 10 80       	push   $0x80108972
80101af3:	e8 6e ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101af8:	83 ec 0c             	sub    $0xc,%esp
80101afb:	68 40 12 11 80       	push   $0x80111240
80101b00:	e8 ea 37 00 00       	call   801052ef <acquire>
80101b05:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b08:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0e:	83 e0 fe             	and    $0xfffffffe,%eax
80101b11:	89 c2                	mov    %eax,%edx
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b19:	83 ec 0c             	sub    $0xc,%esp
80101b1c:	ff 75 08             	pushl  0x8(%ebp)
80101b1f:	e8 b7 35 00 00       	call   801050db <wakeup>
80101b24:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b27:	83 ec 0c             	sub    $0xc,%esp
80101b2a:	68 40 12 11 80       	push   $0x80111240
80101b2f:	e8 22 38 00 00       	call   80105356 <release>
80101b34:	83 c4 10             	add    $0x10,%esp
}
80101b37:	90                   	nop
80101b38:	c9                   	leave  
80101b39:	c3                   	ret    

80101b3a <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b3a:	55                   	push   %ebp
80101b3b:	89 e5                	mov    %esp,%ebp
80101b3d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b40:	83 ec 0c             	sub    $0xc,%esp
80101b43:	68 40 12 11 80       	push   $0x80111240
80101b48:	e8 a2 37 00 00       	call   801052ef <acquire>
80101b4d:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 08             	mov    0x8(%eax),%eax
80101b56:	83 f8 01             	cmp    $0x1,%eax
80101b59:	0f 85 a9 00 00 00    	jne    80101c08 <iput+0xce>
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	8b 40 0c             	mov    0xc(%eax),%eax
80101b65:	83 e0 02             	and    $0x2,%eax
80101b68:	85 c0                	test   %eax,%eax
80101b6a:	0f 84 98 00 00 00    	je     80101c08 <iput+0xce>
80101b70:	8b 45 08             	mov    0x8(%ebp),%eax
80101b73:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b77:	66 85 c0             	test   %ax,%ax
80101b7a:	0f 85 88 00 00 00    	jne    80101c08 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b80:	8b 45 08             	mov    0x8(%ebp),%eax
80101b83:	8b 40 0c             	mov    0xc(%eax),%eax
80101b86:	83 e0 01             	and    $0x1,%eax
80101b89:	85 c0                	test   %eax,%eax
80101b8b:	74 0d                	je     80101b9a <iput+0x60>
      panic("iput busy");
80101b8d:	83 ec 0c             	sub    $0xc,%esp
80101b90:	68 7a 89 10 80       	push   $0x8010897a
80101b95:	e8 cc e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9d:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba0:	83 c8 01             	or     $0x1,%eax
80101ba3:	89 c2                	mov    %eax,%edx
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bab:	83 ec 0c             	sub    $0xc,%esp
80101bae:	68 40 12 11 80       	push   $0x80111240
80101bb3:	e8 9e 37 00 00       	call   80105356 <release>
80101bb8:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bbb:	83 ec 0c             	sub    $0xc,%esp
80101bbe:	ff 75 08             	pushl  0x8(%ebp)
80101bc1:	e8 a8 01 00 00       	call   80101d6e <itrunc>
80101bc6:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	ff 75 08             	pushl  0x8(%ebp)
80101bd8:	e8 b3 fb ff ff       	call   80101790 <iupdate>
80101bdd:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101be0:	83 ec 0c             	sub    $0xc,%esp
80101be3:	68 40 12 11 80       	push   $0x80111240
80101be8:	e8 02 37 00 00       	call   801052ef <acquire>
80101bed:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bfa:	83 ec 0c             	sub    $0xc,%esp
80101bfd:	ff 75 08             	pushl  0x8(%ebp)
80101c00:	e8 d6 34 00 00       	call   801050db <wakeup>
80101c05:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 40 12 11 80       	push   $0x80111240
80101c1f:	e8 32 37 00 00       	call   80105356 <release>
80101c24:	83 c4 10             	add    $0x10,%esp
}
80101c27:	90                   	nop
80101c28:	c9                   	leave  
80101c29:	c3                   	ret    

80101c2a <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c2a:	55                   	push   %ebp
80101c2b:	89 e5                	mov    %esp,%ebp
80101c2d:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	ff 75 08             	pushl  0x8(%ebp)
80101c36:	e8 8d fe ff ff       	call   80101ac8 <iunlock>
80101c3b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c3e:	83 ec 0c             	sub    $0xc,%esp
80101c41:	ff 75 08             	pushl  0x8(%ebp)
80101c44:	e8 f1 fe ff ff       	call   80101b3a <iput>
80101c49:	83 c4 10             	add    $0x10,%esp
}
80101c4c:	90                   	nop
80101c4d:	c9                   	leave  
80101c4e:	c3                   	ret    

80101c4f <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c4f:	55                   	push   %ebp
80101c50:	89 e5                	mov    %esp,%ebp
80101c52:	53                   	push   %ebx
80101c53:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c56:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c5a:	77 42                	ja     80101c9e <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c62:	83 c2 04             	add    $0x4,%edx
80101c65:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c70:	75 24                	jne    80101c96 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	8b 00                	mov    (%eax),%eax
80101c77:	83 ec 0c             	sub    $0xc,%esp
80101c7a:	50                   	push   %eax
80101c7b:	e8 9a f7 ff ff       	call   8010141a <balloc>
80101c80:	83 c4 10             	add    $0x10,%esp
80101c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c8c:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c92:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c99:	e9 cb 00 00 00       	jmp    80101d69 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c9e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ca2:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ca6:	0f 87 b0 00 00 00    	ja     80101d5c <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cac:	8b 45 08             	mov    0x8(%ebp),%eax
80101caf:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb9:	75 1d                	jne    80101cd8 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	8b 00                	mov    (%eax),%eax
80101cc0:	83 ec 0c             	sub    $0xc,%esp
80101cc3:	50                   	push   %eax
80101cc4:	e8 51 f7 ff ff       	call   8010141a <balloc>
80101cc9:	83 c4 10             	add    $0x10,%esp
80101ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd5:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	8b 00                	mov    (%eax),%eax
80101cdd:	83 ec 08             	sub    $0x8,%esp
80101ce0:	ff 75 f4             	pushl  -0xc(%ebp)
80101ce3:	50                   	push   %eax
80101ce4:	e8 cd e4 ff ff       	call   801001b6 <bread>
80101ce9:	83 c4 10             	add    $0x10,%esp
80101cec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf2:	83 c0 18             	add    $0x18,%eax
80101cf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d05:	01 d0                	add    %edx,%eax
80101d07:	8b 00                	mov    (%eax),%eax
80101d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d10:	75 37                	jne    80101d49 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d22:	8b 45 08             	mov    0x8(%ebp),%eax
80101d25:	8b 00                	mov    (%eax),%eax
80101d27:	83 ec 0c             	sub    $0xc,%esp
80101d2a:	50                   	push   %eax
80101d2b:	e8 ea f6 ff ff       	call   8010141a <balloc>
80101d30:	83 c4 10             	add    $0x10,%esp
80101d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d39:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d3b:	83 ec 0c             	sub    $0xc,%esp
80101d3e:	ff 75 f0             	pushl  -0x10(%ebp)
80101d41:	e8 3f 1a 00 00       	call   80103785 <log_write>
80101d46:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d49:	83 ec 0c             	sub    $0xc,%esp
80101d4c:	ff 75 f0             	pushl  -0x10(%ebp)
80101d4f:	e8 da e4 ff ff       	call   8010022e <brelse>
80101d54:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5a:	eb 0d                	jmp    80101d69 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d5c:	83 ec 0c             	sub    $0xc,%esp
80101d5f:	68 84 89 10 80       	push   $0x80108984
80101d64:	e8 fd e7 ff ff       	call   80100566 <panic>
}
80101d69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d6c:	c9                   	leave  
80101d6d:	c3                   	ret    

80101d6e <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d6e:	55                   	push   %ebp
80101d6f:	89 e5                	mov    %esp,%ebp
80101d71:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d7b:	eb 45                	jmp    80101dc2 <itrunc+0x54>
    if(ip->addrs[i]){
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d83:	83 c2 04             	add    $0x4,%edx
80101d86:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8a:	85 c0                	test   %eax,%eax
80101d8c:	74 30                	je     80101dbe <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d94:	83 c2 04             	add    $0x4,%edx
80101d97:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101d9e:	8b 12                	mov    (%edx),%edx
80101da0:	83 ec 08             	sub    $0x8,%esp
80101da3:	50                   	push   %eax
80101da4:	52                   	push   %edx
80101da5:	e8 bc f7 ff ff       	call   80101566 <bfree>
80101daa:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db3:	83 c2 04             	add    $0x4,%edx
80101db6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dbd:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc2:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc6:	7e b5                	jle    80101d7d <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dce:	85 c0                	test   %eax,%eax
80101dd0:	0f 84 a1 00 00 00    	je     80101e77 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd9:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 cb e3 ff ff       	call   801001b6 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 18             	add    $0x18,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd1>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 2e f7 ff ff       	call   80101566 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	pushl  -0x14(%ebp)
80101e4d:	e8 dc e3 ff ff       	call   8010022e <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e5b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5e:	8b 12                	mov    (%edx),%edx
80101e60:	83 ec 08             	sub    $0x8,%esp
80101e63:	50                   	push   %eax
80101e64:	52                   	push   %edx
80101e65:	e8 fc f6 ff ff       	call   80101566 <bfree>
80101e6a:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e70:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e81:	83 ec 0c             	sub    $0xc,%esp
80101e84:	ff 75 08             	pushl  0x8(%ebp)
80101e87:	e8 04 f9 ff ff       	call   80101790 <iupdate>
80101e8c:	83 c4 10             	add    $0x10,%esp
}
80101e8f:	90                   	nop
80101e90:	c9                   	leave  
80101e91:	c3                   	ret    

80101e92 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e92:	55                   	push   %ebp
80101e93:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 00                	mov    (%eax),%eax
80101e9a:	89 c2                	mov    %eax,%edx
80101e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9f:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea5:	8b 50 04             	mov    0x4(%eax),%edx
80101ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eab:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eae:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb1:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb8:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebe:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec5:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	8b 50 18             	mov    0x18(%eax),%edx
80101ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed2:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed5:	90                   	nop
80101ed6:	5d                   	pop    %ebp
80101ed7:	c3                   	ret    

80101ed8 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed8:	55                   	push   %ebp
80101ed9:	89 e5                	mov    %esp,%ebp
80101edb:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ede:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee5:	66 83 f8 03          	cmp    $0x3,%ax
80101ee9:	75 5c                	jne    80101f47 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef2:	66 85 c0             	test   %ax,%ax
80101ef5:	78 20                	js     80101f17 <readi+0x3f>
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efe:	66 83 f8 09          	cmp    $0x9,%ax
80101f02:	7f 13                	jg     80101f17 <readi+0x3f>
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
80101f07:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0b:	98                   	cwtl   
80101f0c:	8b 04 c5 c0 11 11 80 	mov    -0x7feeee40(,%eax,8),%eax
80101f13:	85 c0                	test   %eax,%eax
80101f15:	75 0a                	jne    80101f21 <readi+0x49>
      return -1;
80101f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1c:	e9 0c 01 00 00       	jmp    8010202d <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f21:	8b 45 08             	mov    0x8(%ebp),%eax
80101f24:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f28:	98                   	cwtl   
80101f29:	8b 04 c5 c0 11 11 80 	mov    -0x7feeee40(,%eax,8),%eax
80101f30:	8b 55 14             	mov    0x14(%ebp),%edx
80101f33:	83 ec 04             	sub    $0x4,%esp
80101f36:	52                   	push   %edx
80101f37:	ff 75 0c             	pushl  0xc(%ebp)
80101f3a:	ff 75 08             	pushl  0x8(%ebp)
80101f3d:	ff d0                	call   *%eax
80101f3f:	83 c4 10             	add    $0x10,%esp
80101f42:	e9 e6 00 00 00       	jmp    8010202d <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	8b 40 18             	mov    0x18(%eax),%eax
80101f4d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f50:	72 0d                	jb     80101f5f <readi+0x87>
80101f52:	8b 55 10             	mov    0x10(%ebp),%edx
80101f55:	8b 45 14             	mov    0x14(%ebp),%eax
80101f58:	01 d0                	add    %edx,%eax
80101f5a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f5d:	73 0a                	jae    80101f69 <readi+0x91>
    return -1;
80101f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f64:	e9 c4 00 00 00       	jmp    8010202d <readi+0x155>
  if(off + n > ip->size)
80101f69:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6c:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6f:	01 c2                	add    %eax,%edx
80101f71:	8b 45 08             	mov    0x8(%ebp),%eax
80101f74:	8b 40 18             	mov    0x18(%eax),%eax
80101f77:	39 c2                	cmp    %eax,%edx
80101f79:	76 0c                	jbe    80101f87 <readi+0xaf>
    n = ip->size - off;
80101f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7e:	8b 40 18             	mov    0x18(%eax),%eax
80101f81:	2b 45 10             	sub    0x10(%ebp),%eax
80101f84:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8e:	e9 8b 00 00 00       	jmp    8010201e <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f93:	8b 45 10             	mov    0x10(%ebp),%eax
80101f96:	c1 e8 09             	shr    $0x9,%eax
80101f99:	83 ec 08             	sub    $0x8,%esp
80101f9c:	50                   	push   %eax
80101f9d:	ff 75 08             	pushl  0x8(%ebp)
80101fa0:	e8 aa fc ff ff       	call   80101c4f <bmap>
80101fa5:	83 c4 10             	add    $0x10,%esp
80101fa8:	89 c2                	mov    %eax,%edx
80101faa:	8b 45 08             	mov    0x8(%ebp),%eax
80101fad:	8b 00                	mov    (%eax),%eax
80101faf:	83 ec 08             	sub    $0x8,%esp
80101fb2:	52                   	push   %edx
80101fb3:	50                   	push   %eax
80101fb4:	e8 fd e1 ff ff       	call   801001b6 <bread>
80101fb9:	83 c4 10             	add    $0x10,%esp
80101fbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc7:	ba 00 02 00 00       	mov    $0x200,%edx
80101fcc:	29 c2                	sub    %eax,%edx
80101fce:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd1:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd4:	39 c2                	cmp    %eax,%edx
80101fd6:	0f 46 c2             	cmovbe %edx,%eax
80101fd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdf:	8d 50 18             	lea    0x18(%eax),%edx
80101fe2:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe5:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fea:	01 d0                	add    %edx,%eax
80101fec:	83 ec 04             	sub    $0x4,%esp
80101fef:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff2:	50                   	push   %eax
80101ff3:	ff 75 0c             	pushl  0xc(%ebp)
80101ff6:	e8 16 36 00 00       	call   80105611 <memmove>
80101ffb:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffe:	83 ec 0c             	sub    $0xc,%esp
80102001:	ff 75 f0             	pushl  -0x10(%ebp)
80102004:	e8 25 e2 ff ff       	call   8010022e <brelse>
80102009:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010200c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102012:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102015:	01 45 10             	add    %eax,0x10(%ebp)
80102018:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201b:	01 45 0c             	add    %eax,0xc(%ebp)
8010201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102021:	3b 45 14             	cmp    0x14(%ebp),%eax
80102024:	0f 82 69 ff ff ff    	jb     80101f93 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010202a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202d:	c9                   	leave  
8010202e:	c3                   	ret    

8010202f <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202f:	55                   	push   %ebp
80102030:	89 e5                	mov    %esp,%ebp
80102032:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010203c:	66 83 f8 03          	cmp    $0x3,%ax
80102040:	75 5c                	jne    8010209e <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102049:	66 85 c0             	test   %ax,%ax
8010204c:	78 20                	js     8010206e <writei+0x3f>
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102055:	66 83 f8 09          	cmp    $0x9,%ax
80102059:	7f 13                	jg     8010206e <writei+0x3f>
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102062:	98                   	cwtl   
80102063:	8b 04 c5 c4 11 11 80 	mov    -0x7feeee3c(,%eax,8),%eax
8010206a:	85 c0                	test   %eax,%eax
8010206c:	75 0a                	jne    80102078 <writei+0x49>
      return -1;
8010206e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102073:	e9 3d 01 00 00       	jmp    801021b5 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102078:	8b 45 08             	mov    0x8(%ebp),%eax
8010207b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207f:	98                   	cwtl   
80102080:	8b 04 c5 c4 11 11 80 	mov    -0x7feeee3c(,%eax,8),%eax
80102087:	8b 55 14             	mov    0x14(%ebp),%edx
8010208a:	83 ec 04             	sub    $0x4,%esp
8010208d:	52                   	push   %edx
8010208e:	ff 75 0c             	pushl  0xc(%ebp)
80102091:	ff 75 08             	pushl  0x8(%ebp)
80102094:	ff d0                	call   *%eax
80102096:	83 c4 10             	add    $0x10,%esp
80102099:	e9 17 01 00 00       	jmp    801021b5 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010209e:	8b 45 08             	mov    0x8(%ebp),%eax
801020a1:	8b 40 18             	mov    0x18(%eax),%eax
801020a4:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a7:	72 0d                	jb     801020b6 <writei+0x87>
801020a9:	8b 55 10             	mov    0x10(%ebp),%edx
801020ac:	8b 45 14             	mov    0x14(%ebp),%eax
801020af:	01 d0                	add    %edx,%eax
801020b1:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b4:	73 0a                	jae    801020c0 <writei+0x91>
    return -1;
801020b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bb:	e9 f5 00 00 00       	jmp    801021b5 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020c0:	8b 55 10             	mov    0x10(%ebp),%edx
801020c3:	8b 45 14             	mov    0x14(%ebp),%eax
801020c6:	01 d0                	add    %edx,%eax
801020c8:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020cd:	76 0a                	jbe    801020d9 <writei+0xaa>
    return -1;
801020cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d4:	e9 dc 00 00 00       	jmp    801021b5 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e0:	e9 99 00 00 00       	jmp    8010217e <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e5:	8b 45 10             	mov    0x10(%ebp),%eax
801020e8:	c1 e8 09             	shr    $0x9,%eax
801020eb:	83 ec 08             	sub    $0x8,%esp
801020ee:	50                   	push   %eax
801020ef:	ff 75 08             	pushl  0x8(%ebp)
801020f2:	e8 58 fb ff ff       	call   80101c4f <bmap>
801020f7:	83 c4 10             	add    $0x10,%esp
801020fa:	89 c2                	mov    %eax,%edx
801020fc:	8b 45 08             	mov    0x8(%ebp),%eax
801020ff:	8b 00                	mov    (%eax),%eax
80102101:	83 ec 08             	sub    $0x8,%esp
80102104:	52                   	push   %edx
80102105:	50                   	push   %eax
80102106:	e8 ab e0 ff ff       	call   801001b6 <bread>
8010210b:	83 c4 10             	add    $0x10,%esp
8010210e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102111:	8b 45 10             	mov    0x10(%ebp),%eax
80102114:	25 ff 01 00 00       	and    $0x1ff,%eax
80102119:	ba 00 02 00 00       	mov    $0x200,%edx
8010211e:	29 c2                	sub    %eax,%edx
80102120:	8b 45 14             	mov    0x14(%ebp),%eax
80102123:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102126:	39 c2                	cmp    %eax,%edx
80102128:	0f 46 c2             	cmovbe %edx,%eax
8010212b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010212e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102131:	8d 50 18             	lea    0x18(%eax),%edx
80102134:	8b 45 10             	mov    0x10(%ebp),%eax
80102137:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213c:	01 d0                	add    %edx,%eax
8010213e:	83 ec 04             	sub    $0x4,%esp
80102141:	ff 75 ec             	pushl  -0x14(%ebp)
80102144:	ff 75 0c             	pushl  0xc(%ebp)
80102147:	50                   	push   %eax
80102148:	e8 c4 34 00 00       	call   80105611 <memmove>
8010214d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102150:	83 ec 0c             	sub    $0xc,%esp
80102153:	ff 75 f0             	pushl  -0x10(%ebp)
80102156:	e8 2a 16 00 00       	call   80103785 <log_write>
8010215b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010215e:	83 ec 0c             	sub    $0xc,%esp
80102161:	ff 75 f0             	pushl  -0x10(%ebp)
80102164:	e8 c5 e0 ff ff       	call   8010022e <brelse>
80102169:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 10             	add    %eax,0x10(%ebp)
80102178:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217b:	01 45 0c             	add    %eax,0xc(%ebp)
8010217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102181:	3b 45 14             	cmp    0x14(%ebp),%eax
80102184:	0f 82 5b ff ff ff    	jb     801020e5 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010218a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010218e:	74 22                	je     801021b2 <writei+0x183>
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	8b 40 18             	mov    0x18(%eax),%eax
80102196:	3b 45 10             	cmp    0x10(%ebp),%eax
80102199:	73 17                	jae    801021b2 <writei+0x183>
    ip->size = off;
8010219b:	8b 45 08             	mov    0x8(%ebp),%eax
8010219e:	8b 55 10             	mov    0x10(%ebp),%edx
801021a1:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021a4:	83 ec 0c             	sub    $0xc,%esp
801021a7:	ff 75 08             	pushl  0x8(%ebp)
801021aa:	e8 e1 f5 ff ff       	call   80101790 <iupdate>
801021af:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b2:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b5:	c9                   	leave  
801021b6:	c3                   	ret    

801021b7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b7:	55                   	push   %ebp
801021b8:	89 e5                	mov    %esp,%ebp
801021ba:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bd:	83 ec 04             	sub    $0x4,%esp
801021c0:	6a 0e                	push   $0xe
801021c2:	ff 75 0c             	pushl  0xc(%ebp)
801021c5:	ff 75 08             	pushl  0x8(%ebp)
801021c8:	e8 da 34 00 00       	call   801056a7 <strncmp>
801021cd:	83 c4 10             	add    $0x10,%esp
}
801021d0:	c9                   	leave  
801021d1:	c3                   	ret    

801021d2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d2:	55                   	push   %ebp
801021d3:	89 e5                	mov    %esp,%ebp
801021d5:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021df:	66 83 f8 01          	cmp    $0x1,%ax
801021e3:	74 0d                	je     801021f2 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e5:	83 ec 0c             	sub    $0xc,%esp
801021e8:	68 97 89 10 80       	push   $0x80108997
801021ed:	e8 74 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f9:	eb 7b                	jmp    80102276 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fb:	6a 10                	push   $0x10
801021fd:	ff 75 f4             	pushl  -0xc(%ebp)
80102200:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102203:	50                   	push   %eax
80102204:	ff 75 08             	pushl  0x8(%ebp)
80102207:	e8 cc fc ff ff       	call   80101ed8 <readi>
8010220c:	83 c4 10             	add    $0x10,%esp
8010220f:	83 f8 10             	cmp    $0x10,%eax
80102212:	74 0d                	je     80102221 <dirlookup+0x4f>
      panic("dirlink read");
80102214:	83 ec 0c             	sub    $0xc,%esp
80102217:	68 a9 89 10 80       	push   $0x801089a9
8010221c:	e8 45 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102221:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102225:	66 85 c0             	test   %ax,%ax
80102228:	74 47                	je     80102271 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222a:	83 ec 08             	sub    $0x8,%esp
8010222d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102230:	83 c0 02             	add    $0x2,%eax
80102233:	50                   	push   %eax
80102234:	ff 75 0c             	pushl  0xc(%ebp)
80102237:	e8 7b ff ff ff       	call   801021b7 <namecmp>
8010223c:	83 c4 10             	add    $0x10,%esp
8010223f:	85 c0                	test   %eax,%eax
80102241:	75 2f                	jne    80102272 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102243:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102247:	74 08                	je     80102251 <dirlookup+0x7f>
        *poff = off;
80102249:	8b 45 10             	mov    0x10(%ebp),%eax
8010224c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102251:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102255:	0f b7 c0             	movzwl %ax,%eax
80102258:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	8b 00                	mov    (%eax),%eax
80102260:	83 ec 08             	sub    $0x8,%esp
80102263:	ff 75 f0             	pushl  -0x10(%ebp)
80102266:	50                   	push   %eax
80102267:	e8 e5 f5 ff ff       	call   80101851 <iget>
8010226c:	83 c4 10             	add    $0x10,%esp
8010226f:	eb 19                	jmp    8010228a <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102271:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102272:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102276:	8b 45 08             	mov    0x8(%ebp),%eax
80102279:	8b 40 18             	mov    0x18(%eax),%eax
8010227c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010227f:	0f 87 76 ff ff ff    	ja     801021fb <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102285:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228a:	c9                   	leave  
8010228b:	c3                   	ret    

8010228c <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228c:	55                   	push   %ebp
8010228d:	89 e5                	mov    %esp,%ebp
8010228f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102292:	83 ec 04             	sub    $0x4,%esp
80102295:	6a 00                	push   $0x0
80102297:	ff 75 0c             	pushl  0xc(%ebp)
8010229a:	ff 75 08             	pushl  0x8(%ebp)
8010229d:	e8 30 ff ff ff       	call   801021d2 <dirlookup>
801022a2:	83 c4 10             	add    $0x10,%esp
801022a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ac:	74 18                	je     801022c6 <dirlink+0x3a>
    iput(ip);
801022ae:	83 ec 0c             	sub    $0xc,%esp
801022b1:	ff 75 f0             	pushl  -0x10(%ebp)
801022b4:	e8 81 f8 ff ff       	call   80101b3a <iput>
801022b9:	83 c4 10             	add    $0x10,%esp
    return -1;
801022bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c1:	e9 9c 00 00 00       	jmp    80102362 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cd:	eb 39                	jmp    80102308 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d2:	6a 10                	push   $0x10
801022d4:	50                   	push   %eax
801022d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d8:	50                   	push   %eax
801022d9:	ff 75 08             	pushl  0x8(%ebp)
801022dc:	e8 f7 fb ff ff       	call   80101ed8 <readi>
801022e1:	83 c4 10             	add    $0x10,%esp
801022e4:	83 f8 10             	cmp    $0x10,%eax
801022e7:	74 0d                	je     801022f6 <dirlink+0x6a>
      panic("dirlink read");
801022e9:	83 ec 0c             	sub    $0xc,%esp
801022ec:	68 a9 89 10 80       	push   $0x801089a9
801022f1:	e8 70 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fa:	66 85 c0             	test   %ax,%ax
801022fd:	74 18                	je     80102317 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102302:	83 c0 10             	add    $0x10,%eax
80102305:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102308:	8b 45 08             	mov    0x8(%ebp),%eax
8010230b:	8b 50 18             	mov    0x18(%eax),%edx
8010230e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102311:	39 c2                	cmp    %eax,%edx
80102313:	77 ba                	ja     801022cf <dirlink+0x43>
80102315:	eb 01                	jmp    80102318 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102317:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102318:	83 ec 04             	sub    $0x4,%esp
8010231b:	6a 0e                	push   $0xe
8010231d:	ff 75 0c             	pushl  0xc(%ebp)
80102320:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102323:	83 c0 02             	add    $0x2,%eax
80102326:	50                   	push   %eax
80102327:	e8 d1 33 00 00       	call   801056fd <strncpy>
8010232c:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010232f:	8b 45 10             	mov    0x10(%ebp),%eax
80102332:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102339:	6a 10                	push   $0x10
8010233b:	50                   	push   %eax
8010233c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233f:	50                   	push   %eax
80102340:	ff 75 08             	pushl  0x8(%ebp)
80102343:	e8 e7 fc ff ff       	call   8010202f <writei>
80102348:	83 c4 10             	add    $0x10,%esp
8010234b:	83 f8 10             	cmp    $0x10,%eax
8010234e:	74 0d                	je     8010235d <dirlink+0xd1>
    panic("dirlink");
80102350:	83 ec 0c             	sub    $0xc,%esp
80102353:	68 b6 89 10 80       	push   $0x801089b6
80102358:	e8 09 e2 ff ff       	call   80100566 <panic>
  
  return 0;
8010235d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102362:	c9                   	leave  
80102363:	c3                   	ret    

80102364 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102364:	55                   	push   %ebp
80102365:	89 e5                	mov    %esp,%ebp
80102367:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236a:	eb 04                	jmp    80102370 <skipelem+0xc>
    path++;
8010236c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	0f b6 00             	movzbl (%eax),%eax
80102376:	3c 2f                	cmp    $0x2f,%al
80102378:	74 f2                	je     8010236c <skipelem+0x8>
    path++;
  if(*path == 0)
8010237a:	8b 45 08             	mov    0x8(%ebp),%eax
8010237d:	0f b6 00             	movzbl (%eax),%eax
80102380:	84 c0                	test   %al,%al
80102382:	75 07                	jne    8010238b <skipelem+0x27>
    return 0;
80102384:	b8 00 00 00 00       	mov    $0x0,%eax
80102389:	eb 7b                	jmp    80102406 <skipelem+0xa2>
  s = path;
8010238b:	8b 45 08             	mov    0x8(%ebp),%eax
8010238e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102391:	eb 04                	jmp    80102397 <skipelem+0x33>
    path++;
80102393:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102397:	8b 45 08             	mov    0x8(%ebp),%eax
8010239a:	0f b6 00             	movzbl (%eax),%eax
8010239d:	3c 2f                	cmp    $0x2f,%al
8010239f:	74 0a                	je     801023ab <skipelem+0x47>
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	0f b6 00             	movzbl (%eax),%eax
801023a7:	84 c0                	test   %al,%al
801023a9:	75 e8                	jne    80102393 <skipelem+0x2f>
    path++;
  len = path - s;
801023ab:	8b 55 08             	mov    0x8(%ebp),%edx
801023ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b1:	29 c2                	sub    %eax,%edx
801023b3:	89 d0                	mov    %edx,%eax
801023b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b8:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023bc:	7e 15                	jle    801023d3 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023be:	83 ec 04             	sub    $0x4,%esp
801023c1:	6a 0e                	push   $0xe
801023c3:	ff 75 f4             	pushl  -0xc(%ebp)
801023c6:	ff 75 0c             	pushl  0xc(%ebp)
801023c9:	e8 43 32 00 00       	call   80105611 <memmove>
801023ce:	83 c4 10             	add    $0x10,%esp
801023d1:	eb 26                	jmp    801023f9 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d6:	83 ec 04             	sub    $0x4,%esp
801023d9:	50                   	push   %eax
801023da:	ff 75 f4             	pushl  -0xc(%ebp)
801023dd:	ff 75 0c             	pushl  0xc(%ebp)
801023e0:	e8 2c 32 00 00       	call   80105611 <memmove>
801023e5:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ee:	01 d0                	add    %edx,%eax
801023f0:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f3:	eb 04                	jmp    801023f9 <skipelem+0x95>
    path++;
801023f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
801023fc:	0f b6 00             	movzbl (%eax),%eax
801023ff:	3c 2f                	cmp    $0x2f,%al
80102401:	74 f2                	je     801023f5 <skipelem+0x91>
    path++;
  return path;
80102403:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102406:	c9                   	leave  
80102407:	c3                   	ret    

80102408 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102408:	55                   	push   %ebp
80102409:	89 e5                	mov    %esp,%ebp
8010240b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240e:	8b 45 08             	mov    0x8(%ebp),%eax
80102411:	0f b6 00             	movzbl (%eax),%eax
80102414:	3c 2f                	cmp    $0x2f,%al
80102416:	75 17                	jne    8010242f <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102418:	83 ec 08             	sub    $0x8,%esp
8010241b:	6a 01                	push   $0x1
8010241d:	6a 01                	push   $0x1
8010241f:	e8 2d f4 ff ff       	call   80101851 <iget>
80102424:	83 c4 10             	add    $0x10,%esp
80102427:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010242a:	e9 bb 00 00 00       	jmp    801024ea <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010242f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102435:	8b 40 68             	mov    0x68(%eax),%eax
80102438:	83 ec 0c             	sub    $0xc,%esp
8010243b:	50                   	push   %eax
8010243c:	e8 ef f4 ff ff       	call   80101930 <idup>
80102441:	83 c4 10             	add    $0x10,%esp
80102444:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102447:	e9 9e 00 00 00       	jmp    801024ea <namex+0xe2>
    ilock(ip);
8010244c:	83 ec 0c             	sub    $0xc,%esp
8010244f:	ff 75 f4             	pushl  -0xc(%ebp)
80102452:	e8 13 f5 ff ff       	call   8010196a <ilock>
80102457:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102461:	66 83 f8 01          	cmp    $0x1,%ax
80102465:	74 18                	je     8010247f <namex+0x77>
      iunlockput(ip);
80102467:	83 ec 0c             	sub    $0xc,%esp
8010246a:	ff 75 f4             	pushl  -0xc(%ebp)
8010246d:	e8 b8 f7 ff ff       	call   80101c2a <iunlockput>
80102472:	83 c4 10             	add    $0x10,%esp
      return 0;
80102475:	b8 00 00 00 00       	mov    $0x0,%eax
8010247a:	e9 a7 00 00 00       	jmp    80102526 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010247f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102483:	74 20                	je     801024a5 <namex+0x9d>
80102485:	8b 45 08             	mov    0x8(%ebp),%eax
80102488:	0f b6 00             	movzbl (%eax),%eax
8010248b:	84 c0                	test   %al,%al
8010248d:	75 16                	jne    801024a5 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010248f:	83 ec 0c             	sub    $0xc,%esp
80102492:	ff 75 f4             	pushl  -0xc(%ebp)
80102495:	e8 2e f6 ff ff       	call   80101ac8 <iunlock>
8010249a:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a0:	e9 81 00 00 00       	jmp    80102526 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a5:	83 ec 04             	sub    $0x4,%esp
801024a8:	6a 00                	push   $0x0
801024aa:	ff 75 10             	pushl  0x10(%ebp)
801024ad:	ff 75 f4             	pushl  -0xc(%ebp)
801024b0:	e8 1d fd ff ff       	call   801021d2 <dirlookup>
801024b5:	83 c4 10             	add    $0x10,%esp
801024b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bf:	75 15                	jne    801024d6 <namex+0xce>
      iunlockput(ip);
801024c1:	83 ec 0c             	sub    $0xc,%esp
801024c4:	ff 75 f4             	pushl  -0xc(%ebp)
801024c7:	e8 5e f7 ff ff       	call   80101c2a <iunlockput>
801024cc:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cf:	b8 00 00 00 00       	mov    $0x0,%eax
801024d4:	eb 50                	jmp    80102526 <namex+0x11e>
    }
    iunlockput(ip);
801024d6:	83 ec 0c             	sub    $0xc,%esp
801024d9:	ff 75 f4             	pushl  -0xc(%ebp)
801024dc:	e8 49 f7 ff ff       	call   80101c2a <iunlockput>
801024e1:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024ea:	83 ec 08             	sub    $0x8,%esp
801024ed:	ff 75 10             	pushl  0x10(%ebp)
801024f0:	ff 75 08             	pushl  0x8(%ebp)
801024f3:	e8 6c fe ff ff       	call   80102364 <skipelem>
801024f8:	83 c4 10             	add    $0x10,%esp
801024fb:	89 45 08             	mov    %eax,0x8(%ebp)
801024fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102502:	0f 85 44 ff ff ff    	jne    8010244c <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102508:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250c:	74 15                	je     80102523 <namex+0x11b>
    iput(ip);
8010250e:	83 ec 0c             	sub    $0xc,%esp
80102511:	ff 75 f4             	pushl  -0xc(%ebp)
80102514:	e8 21 f6 ff ff       	call   80101b3a <iput>
80102519:	83 c4 10             	add    $0x10,%esp
    return 0;
8010251c:	b8 00 00 00 00       	mov    $0x0,%eax
80102521:	eb 03                	jmp    80102526 <namex+0x11e>
  }
  return ip;
80102523:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102526:	c9                   	leave  
80102527:	c3                   	ret    

80102528 <namei>:

struct inode*
namei(char *path)
{
80102528:	55                   	push   %ebp
80102529:	89 e5                	mov    %esp,%ebp
8010252b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252e:	83 ec 04             	sub    $0x4,%esp
80102531:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102534:	50                   	push   %eax
80102535:	6a 00                	push   $0x0
80102537:	ff 75 08             	pushl  0x8(%ebp)
8010253a:	e8 c9 fe ff ff       	call   80102408 <namex>
8010253f:	83 c4 10             	add    $0x10,%esp
}
80102542:	c9                   	leave  
80102543:	c3                   	ret    

80102544 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102544:	55                   	push   %ebp
80102545:	89 e5                	mov    %esp,%ebp
80102547:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010254a:	83 ec 04             	sub    $0x4,%esp
8010254d:	ff 75 0c             	pushl  0xc(%ebp)
80102550:	6a 01                	push   $0x1
80102552:	ff 75 08             	pushl  0x8(%ebp)
80102555:	e8 ae fe ff ff       	call   80102408 <namex>
8010255a:	83 c4 10             	add    $0x10,%esp
}
8010255d:	c9                   	leave  
8010255e:	c3                   	ret    

8010255f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010255f:	55                   	push   %ebp
80102560:	89 e5                	mov    %esp,%ebp
80102562:	83 ec 14             	sub    $0x14,%esp
80102565:	8b 45 08             	mov    0x8(%ebp),%eax
80102568:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010256c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102570:	89 c2                	mov    %eax,%edx
80102572:	ec                   	in     (%dx),%al
80102573:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102576:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010257a:	c9                   	leave  
8010257b:	c3                   	ret    

8010257c <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010257c:	55                   	push   %ebp
8010257d:	89 e5                	mov    %esp,%ebp
8010257f:	57                   	push   %edi
80102580:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102581:	8b 55 08             	mov    0x8(%ebp),%edx
80102584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102587:	8b 45 10             	mov    0x10(%ebp),%eax
8010258a:	89 cb                	mov    %ecx,%ebx
8010258c:	89 df                	mov    %ebx,%edi
8010258e:	89 c1                	mov    %eax,%ecx
80102590:	fc                   	cld    
80102591:	f3 6d                	rep insl (%dx),%es:(%edi)
80102593:	89 c8                	mov    %ecx,%eax
80102595:	89 fb                	mov    %edi,%ebx
80102597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010259a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010259d:	90                   	nop
8010259e:	5b                   	pop    %ebx
8010259f:	5f                   	pop    %edi
801025a0:	5d                   	pop    %ebp
801025a1:	c3                   	ret    

801025a2 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025a2:	55                   	push   %ebp
801025a3:	89 e5                	mov    %esp,%ebp
801025a5:	83 ec 08             	sub    $0x8,%esp
801025a8:	8b 55 08             	mov    0x8(%ebp),%edx
801025ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ae:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025b2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025bd:	ee                   	out    %al,(%dx)
}
801025be:	90                   	nop
801025bf:	c9                   	leave  
801025c0:	c3                   	ret    

801025c1 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025c1:	55                   	push   %ebp
801025c2:	89 e5                	mov    %esp,%ebp
801025c4:	56                   	push   %esi
801025c5:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025c6:	8b 55 08             	mov    0x8(%ebp),%edx
801025c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025cc:	8b 45 10             	mov    0x10(%ebp),%eax
801025cf:	89 cb                	mov    %ecx,%ebx
801025d1:	89 de                	mov    %ebx,%esi
801025d3:	89 c1                	mov    %eax,%ecx
801025d5:	fc                   	cld    
801025d6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025d8:	89 c8                	mov    %ecx,%eax
801025da:	89 f3                	mov    %esi,%ebx
801025dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025df:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025e2:	90                   	nop
801025e3:	5b                   	pop    %ebx
801025e4:	5e                   	pop    %esi
801025e5:	5d                   	pop    %ebp
801025e6:	c3                   	ret    

801025e7 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025e7:	55                   	push   %ebp
801025e8:	89 e5                	mov    %esp,%ebp
801025ea:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025ed:	90                   	nop
801025ee:	68 f7 01 00 00       	push   $0x1f7
801025f3:	e8 67 ff ff ff       	call   8010255f <inb>
801025f8:	83 c4 04             	add    $0x4,%esp
801025fb:	0f b6 c0             	movzbl %al,%eax
801025fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102601:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102604:	25 c0 00 00 00       	and    $0xc0,%eax
80102609:	83 f8 40             	cmp    $0x40,%eax
8010260c:	75 e0                	jne    801025ee <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010260e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102612:	74 11                	je     80102625 <idewait+0x3e>
80102614:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102617:	83 e0 21             	and    $0x21,%eax
8010261a:	85 c0                	test   %eax,%eax
8010261c:	74 07                	je     80102625 <idewait+0x3e>
    return -1;
8010261e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102623:	eb 05                	jmp    8010262a <idewait+0x43>
  return 0;
80102625:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262a:	c9                   	leave  
8010262b:	c3                   	ret    

8010262c <ideinit>:

void
ideinit(void)
{
8010262c:	55                   	push   %ebp
8010262d:	89 e5                	mov    %esp,%ebp
8010262f:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102632:	83 ec 08             	sub    $0x8,%esp
80102635:	68 be 89 10 80       	push   $0x801089be
8010263a:	68 00 b6 10 80       	push   $0x8010b600
8010263f:	e8 89 2c 00 00       	call   801052cd <initlock>
80102644:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102647:	83 ec 0c             	sub    $0xc,%esp
8010264a:	6a 0e                	push   $0xe
8010264c:	e8 da 18 00 00       	call   80103f2b <picenable>
80102651:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102654:	a1 40 29 11 80       	mov    0x80112940,%eax
80102659:	83 e8 01             	sub    $0x1,%eax
8010265c:	83 ec 08             	sub    $0x8,%esp
8010265f:	50                   	push   %eax
80102660:	6a 0e                	push   $0xe
80102662:	e8 73 04 00 00       	call   80102ada <ioapicenable>
80102667:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010266a:	83 ec 0c             	sub    $0xc,%esp
8010266d:	6a 00                	push   $0x0
8010266f:	e8 73 ff ff ff       	call   801025e7 <idewait>
80102674:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102677:	83 ec 08             	sub    $0x8,%esp
8010267a:	68 f0 00 00 00       	push   $0xf0
8010267f:	68 f6 01 00 00       	push   $0x1f6
80102684:	e8 19 ff ff ff       	call   801025a2 <outb>
80102689:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010268c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102693:	eb 24                	jmp    801026b9 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102695:	83 ec 0c             	sub    $0xc,%esp
80102698:	68 f7 01 00 00       	push   $0x1f7
8010269d:	e8 bd fe ff ff       	call   8010255f <inb>
801026a2:	83 c4 10             	add    $0x10,%esp
801026a5:	84 c0                	test   %al,%al
801026a7:	74 0c                	je     801026b5 <ideinit+0x89>
      havedisk1 = 1;
801026a9:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801026b0:	00 00 00 
      break;
801026b3:	eb 0d                	jmp    801026c2 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026b9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026c0:	7e d3                	jle    80102695 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026c2:	83 ec 08             	sub    $0x8,%esp
801026c5:	68 e0 00 00 00       	push   $0xe0
801026ca:	68 f6 01 00 00       	push   $0x1f6
801026cf:	e8 ce fe ff ff       	call   801025a2 <outb>
801026d4:	83 c4 10             	add    $0x10,%esp
}
801026d7:	90                   	nop
801026d8:	c9                   	leave  
801026d9:	c3                   	ret    

801026da <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026da:	55                   	push   %ebp
801026db:	89 e5                	mov    %esp,%ebp
801026dd:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026e4:	75 0d                	jne    801026f3 <idestart+0x19>
    panic("idestart");
801026e6:	83 ec 0c             	sub    $0xc,%esp
801026e9:	68 c2 89 10 80       	push   $0x801089c2
801026ee:	e8 73 de ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
801026f3:	8b 45 08             	mov    0x8(%ebp),%eax
801026f6:	8b 40 08             	mov    0x8(%eax),%eax
801026f9:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026fe:	76 0d                	jbe    8010270d <idestart+0x33>
    panic("incorrect blockno");
80102700:	83 ec 0c             	sub    $0xc,%esp
80102703:	68 cb 89 10 80       	push   $0x801089cb
80102708:	e8 59 de ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010270d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	8b 50 08             	mov    0x8(%eax),%edx
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	0f af c2             	imul   %edx,%eax
80102720:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102723:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102727:	7e 0d                	jle    80102736 <idestart+0x5c>
80102729:	83 ec 0c             	sub    $0xc,%esp
8010272c:	68 c2 89 10 80       	push   $0x801089c2
80102731:	e8 30 de ff ff       	call   80100566 <panic>
  
  idewait(0);
80102736:	83 ec 0c             	sub    $0xc,%esp
80102739:	6a 00                	push   $0x0
8010273b:	e8 a7 fe ff ff       	call   801025e7 <idewait>
80102740:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102743:	83 ec 08             	sub    $0x8,%esp
80102746:	6a 00                	push   $0x0
80102748:	68 f6 03 00 00       	push   $0x3f6
8010274d:	e8 50 fe ff ff       	call   801025a2 <outb>
80102752:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	0f b6 c0             	movzbl %al,%eax
8010275b:	83 ec 08             	sub    $0x8,%esp
8010275e:	50                   	push   %eax
8010275f:	68 f2 01 00 00       	push   $0x1f2
80102764:	e8 39 fe ff ff       	call   801025a2 <outb>
80102769:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010276c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010276f:	0f b6 c0             	movzbl %al,%eax
80102772:	83 ec 08             	sub    $0x8,%esp
80102775:	50                   	push   %eax
80102776:	68 f3 01 00 00       	push   $0x1f3
8010277b:	e8 22 fe ff ff       	call   801025a2 <outb>
80102780:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102786:	c1 f8 08             	sar    $0x8,%eax
80102789:	0f b6 c0             	movzbl %al,%eax
8010278c:	83 ec 08             	sub    $0x8,%esp
8010278f:	50                   	push   %eax
80102790:	68 f4 01 00 00       	push   $0x1f4
80102795:	e8 08 fe ff ff       	call   801025a2 <outb>
8010279a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010279d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a0:	c1 f8 10             	sar    $0x10,%eax
801027a3:	0f b6 c0             	movzbl %al,%eax
801027a6:	83 ec 08             	sub    $0x8,%esp
801027a9:	50                   	push   %eax
801027aa:	68 f5 01 00 00       	push   $0x1f5
801027af:	e8 ee fd ff ff       	call   801025a2 <outb>
801027b4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027b7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ba:	8b 40 04             	mov    0x4(%eax),%eax
801027bd:	83 e0 01             	and    $0x1,%eax
801027c0:	c1 e0 04             	shl    $0x4,%eax
801027c3:	89 c2                	mov    %eax,%edx
801027c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c8:	c1 f8 18             	sar    $0x18,%eax
801027cb:	83 e0 0f             	and    $0xf,%eax
801027ce:	09 d0                	or     %edx,%eax
801027d0:	83 c8 e0             	or     $0xffffffe0,%eax
801027d3:	0f b6 c0             	movzbl %al,%eax
801027d6:	83 ec 08             	sub    $0x8,%esp
801027d9:	50                   	push   %eax
801027da:	68 f6 01 00 00       	push   $0x1f6
801027df:	e8 be fd ff ff       	call   801025a2 <outb>
801027e4:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027e7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ea:	8b 00                	mov    (%eax),%eax
801027ec:	83 e0 04             	and    $0x4,%eax
801027ef:	85 c0                	test   %eax,%eax
801027f1:	74 30                	je     80102823 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
801027f3:	83 ec 08             	sub    $0x8,%esp
801027f6:	6a 30                	push   $0x30
801027f8:	68 f7 01 00 00       	push   $0x1f7
801027fd:	e8 a0 fd ff ff       	call   801025a2 <outb>
80102802:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102805:	8b 45 08             	mov    0x8(%ebp),%eax
80102808:	83 c0 18             	add    $0x18,%eax
8010280b:	83 ec 04             	sub    $0x4,%esp
8010280e:	68 80 00 00 00       	push   $0x80
80102813:	50                   	push   %eax
80102814:	68 f0 01 00 00       	push   $0x1f0
80102819:	e8 a3 fd ff ff       	call   801025c1 <outsl>
8010281e:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102821:	eb 12                	jmp    80102835 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102823:	83 ec 08             	sub    $0x8,%esp
80102826:	6a 20                	push   $0x20
80102828:	68 f7 01 00 00       	push   $0x1f7
8010282d:	e8 70 fd ff ff       	call   801025a2 <outb>
80102832:	83 c4 10             	add    $0x10,%esp
  }
}
80102835:	90                   	nop
80102836:	c9                   	leave  
80102837:	c3                   	ret    

80102838 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102838:	55                   	push   %ebp
80102839:	89 e5                	mov    %esp,%ebp
8010283b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010283e:	83 ec 0c             	sub    $0xc,%esp
80102841:	68 00 b6 10 80       	push   $0x8010b600
80102846:	e8 a4 2a 00 00       	call   801052ef <acquire>
8010284b:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
8010284e:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102853:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102856:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010285a:	75 15                	jne    80102871 <ideintr+0x39>
    release(&idelock);
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 00 b6 10 80       	push   $0x8010b600
80102864:	e8 ed 2a 00 00       	call   80105356 <release>
80102869:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010286c:	e9 9a 00 00 00       	jmp    8010290b <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102874:	8b 40 14             	mov    0x14(%eax),%eax
80102877:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010287c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287f:	8b 00                	mov    (%eax),%eax
80102881:	83 e0 04             	and    $0x4,%eax
80102884:	85 c0                	test   %eax,%eax
80102886:	75 2d                	jne    801028b5 <ideintr+0x7d>
80102888:	83 ec 0c             	sub    $0xc,%esp
8010288b:	6a 01                	push   $0x1
8010288d:	e8 55 fd ff ff       	call   801025e7 <idewait>
80102892:	83 c4 10             	add    $0x10,%esp
80102895:	85 c0                	test   %eax,%eax
80102897:	78 1c                	js     801028b5 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289c:	83 c0 18             	add    $0x18,%eax
8010289f:	83 ec 04             	sub    $0x4,%esp
801028a2:	68 80 00 00 00       	push   $0x80
801028a7:	50                   	push   %eax
801028a8:	68 f0 01 00 00       	push   $0x1f0
801028ad:	e8 ca fc ff ff       	call   8010257c <insl>
801028b2:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b8:	8b 00                	mov    (%eax),%eax
801028ba:	83 c8 02             	or     $0x2,%eax
801028bd:	89 c2                	mov    %eax,%edx
801028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c2:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c7:	8b 00                	mov    (%eax),%eax
801028c9:	83 e0 fb             	and    $0xfffffffb,%eax
801028cc:	89 c2                	mov    %eax,%edx
801028ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028d3:	83 ec 0c             	sub    $0xc,%esp
801028d6:	ff 75 f4             	pushl  -0xc(%ebp)
801028d9:	e8 fd 27 00 00       	call   801050db <wakeup>
801028de:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028e1:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028e6:	85 c0                	test   %eax,%eax
801028e8:	74 11                	je     801028fb <ideintr+0xc3>
    idestart(idequeue);
801028ea:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028ef:	83 ec 0c             	sub    $0xc,%esp
801028f2:	50                   	push   %eax
801028f3:	e8 e2 fd ff ff       	call   801026da <idestart>
801028f8:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801028fb:	83 ec 0c             	sub    $0xc,%esp
801028fe:	68 00 b6 10 80       	push   $0x8010b600
80102903:	e8 4e 2a 00 00       	call   80105356 <release>
80102908:	83 c4 10             	add    $0x10,%esp
}
8010290b:	c9                   	leave  
8010290c:	c3                   	ret    

8010290d <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010290d:	55                   	push   %ebp
8010290e:	89 e5                	mov    %esp,%ebp
80102910:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102913:	8b 45 08             	mov    0x8(%ebp),%eax
80102916:	8b 00                	mov    (%eax),%eax
80102918:	83 e0 01             	and    $0x1,%eax
8010291b:	85 c0                	test   %eax,%eax
8010291d:	75 0d                	jne    8010292c <iderw+0x1f>
    panic("iderw: buf not busy");
8010291f:	83 ec 0c             	sub    $0xc,%esp
80102922:	68 dd 89 10 80       	push   $0x801089dd
80102927:	e8 3a dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010292c:	8b 45 08             	mov    0x8(%ebp),%eax
8010292f:	8b 00                	mov    (%eax),%eax
80102931:	83 e0 06             	and    $0x6,%eax
80102934:	83 f8 02             	cmp    $0x2,%eax
80102937:	75 0d                	jne    80102946 <iderw+0x39>
    panic("iderw: nothing to do");
80102939:	83 ec 0c             	sub    $0xc,%esp
8010293c:	68 f1 89 10 80       	push   $0x801089f1
80102941:	e8 20 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102946:	8b 45 08             	mov    0x8(%ebp),%eax
80102949:	8b 40 04             	mov    0x4(%eax),%eax
8010294c:	85 c0                	test   %eax,%eax
8010294e:	74 16                	je     80102966 <iderw+0x59>
80102950:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102955:	85 c0                	test   %eax,%eax
80102957:	75 0d                	jne    80102966 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102959:	83 ec 0c             	sub    $0xc,%esp
8010295c:	68 06 8a 10 80       	push   $0x80108a06
80102961:	e8 00 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102966:	83 ec 0c             	sub    $0xc,%esp
80102969:	68 00 b6 10 80       	push   $0x8010b600
8010296e:	e8 7c 29 00 00       	call   801052ef <acquire>
80102973:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102976:	8b 45 08             	mov    0x8(%ebp),%eax
80102979:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102980:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102987:	eb 0b                	jmp    80102994 <iderw+0x87>
80102989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298c:	8b 00                	mov    (%eax),%eax
8010298e:	83 c0 14             	add    $0x14,%eax
80102991:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102997:	8b 00                	mov    (%eax),%eax
80102999:	85 c0                	test   %eax,%eax
8010299b:	75 ec                	jne    80102989 <iderw+0x7c>
    ;
  *pp = b;
8010299d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a0:	8b 55 08             	mov    0x8(%ebp),%edx
801029a3:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029a5:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801029aa:	3b 45 08             	cmp    0x8(%ebp),%eax
801029ad:	75 23                	jne    801029d2 <iderw+0xc5>
    idestart(b);
801029af:	83 ec 0c             	sub    $0xc,%esp
801029b2:	ff 75 08             	pushl  0x8(%ebp)
801029b5:	e8 20 fd ff ff       	call   801026da <idestart>
801029ba:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029bd:	eb 13                	jmp    801029d2 <iderw+0xc5>
    sleep(b, &idelock);
801029bf:	83 ec 08             	sub    $0x8,%esp
801029c2:	68 00 b6 10 80       	push   $0x8010b600
801029c7:	ff 75 08             	pushl  0x8(%ebp)
801029ca:	e8 1e 26 00 00       	call   80104fed <sleep>
801029cf:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029d2:	8b 45 08             	mov    0x8(%ebp),%eax
801029d5:	8b 00                	mov    (%eax),%eax
801029d7:	83 e0 06             	and    $0x6,%eax
801029da:	83 f8 02             	cmp    $0x2,%eax
801029dd:	75 e0                	jne    801029bf <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801029df:	83 ec 0c             	sub    $0xc,%esp
801029e2:	68 00 b6 10 80       	push   $0x8010b600
801029e7:	e8 6a 29 00 00       	call   80105356 <release>
801029ec:	83 c4 10             	add    $0x10,%esp
}
801029ef:	90                   	nop
801029f0:	c9                   	leave  
801029f1:	c3                   	ret    

801029f2 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029f2:	55                   	push   %ebp
801029f3:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029f5:	a1 14 22 11 80       	mov    0x80112214,%eax
801029fa:	8b 55 08             	mov    0x8(%ebp),%edx
801029fd:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029ff:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a04:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a07:	5d                   	pop    %ebp
80102a08:	c3                   	ret    

80102a09 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a09:	55                   	push   %ebp
80102a0a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a0c:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a11:	8b 55 08             	mov    0x8(%ebp),%edx
80102a14:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a16:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a1e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a21:	90                   	nop
80102a22:	5d                   	pop    %ebp
80102a23:	c3                   	ret    

80102a24 <ioapicinit>:

void
ioapicinit(void)
{
80102a24:	55                   	push   %ebp
80102a25:	89 e5                	mov    %esp,%ebp
80102a27:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a2a:	a1 44 23 11 80       	mov    0x80112344,%eax
80102a2f:	85 c0                	test   %eax,%eax
80102a31:	0f 84 a0 00 00 00    	je     80102ad7 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a37:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
80102a3e:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a41:	6a 01                	push   $0x1
80102a43:	e8 aa ff ff ff       	call   801029f2 <ioapicread>
80102a48:	83 c4 04             	add    $0x4,%esp
80102a4b:	c1 e8 10             	shr    $0x10,%eax
80102a4e:	25 ff 00 00 00       	and    $0xff,%eax
80102a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a56:	6a 00                	push   $0x0
80102a58:	e8 95 ff ff ff       	call   801029f2 <ioapicread>
80102a5d:	83 c4 04             	add    $0x4,%esp
80102a60:	c1 e8 18             	shr    $0x18,%eax
80102a63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a66:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
80102a6d:	0f b6 c0             	movzbl %al,%eax
80102a70:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a73:	74 10                	je     80102a85 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a75:	83 ec 0c             	sub    $0xc,%esp
80102a78:	68 24 8a 10 80       	push   $0x80108a24
80102a7d:	e8 44 d9 ff ff       	call   801003c6 <cprintf>
80102a82:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a8c:	eb 3f                	jmp    80102acd <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a91:	83 c0 20             	add    $0x20,%eax
80102a94:	0d 00 00 01 00       	or     $0x10000,%eax
80102a99:	89 c2                	mov    %eax,%edx
80102a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9e:	83 c0 08             	add    $0x8,%eax
80102aa1:	01 c0                	add    %eax,%eax
80102aa3:	83 ec 08             	sub    $0x8,%esp
80102aa6:	52                   	push   %edx
80102aa7:	50                   	push   %eax
80102aa8:	e8 5c ff ff ff       	call   80102a09 <ioapicwrite>
80102aad:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab3:	83 c0 08             	add    $0x8,%eax
80102ab6:	01 c0                	add    %eax,%eax
80102ab8:	83 c0 01             	add    $0x1,%eax
80102abb:	83 ec 08             	sub    $0x8,%esp
80102abe:	6a 00                	push   $0x0
80102ac0:	50                   	push   %eax
80102ac1:	e8 43 ff ff ff       	call   80102a09 <ioapicwrite>
80102ac6:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ac9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ad3:	7e b9                	jle    80102a8e <ioapicinit+0x6a>
80102ad5:	eb 01                	jmp    80102ad8 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102ad7:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ad8:	c9                   	leave  
80102ad9:	c3                   	ret    

80102ada <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ada:	55                   	push   %ebp
80102adb:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102add:	a1 44 23 11 80       	mov    0x80112344,%eax
80102ae2:	85 c0                	test   %eax,%eax
80102ae4:	74 39                	je     80102b1f <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae9:	83 c0 20             	add    $0x20,%eax
80102aec:	89 c2                	mov    %eax,%edx
80102aee:	8b 45 08             	mov    0x8(%ebp),%eax
80102af1:	83 c0 08             	add    $0x8,%eax
80102af4:	01 c0                	add    %eax,%eax
80102af6:	52                   	push   %edx
80102af7:	50                   	push   %eax
80102af8:	e8 0c ff ff ff       	call   80102a09 <ioapicwrite>
80102afd:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b00:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b03:	c1 e0 18             	shl    $0x18,%eax
80102b06:	89 c2                	mov    %eax,%edx
80102b08:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0b:	83 c0 08             	add    $0x8,%eax
80102b0e:	01 c0                	add    %eax,%eax
80102b10:	83 c0 01             	add    $0x1,%eax
80102b13:	52                   	push   %edx
80102b14:	50                   	push   %eax
80102b15:	e8 ef fe ff ff       	call   80102a09 <ioapicwrite>
80102b1a:	83 c4 08             	add    $0x8,%esp
80102b1d:	eb 01                	jmp    80102b20 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102b1f:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102b20:	c9                   	leave  
80102b21:	c3                   	ret    

80102b22 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b22:	55                   	push   %ebp
80102b23:	89 e5                	mov    %esp,%ebp
80102b25:	8b 45 08             	mov    0x8(%ebp),%eax
80102b28:	05 00 00 00 80       	add    $0x80000000,%eax
80102b2d:	5d                   	pop    %ebp
80102b2e:	c3                   	ret    

80102b2f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
80102b32:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b35:	83 ec 08             	sub    $0x8,%esp
80102b38:	68 56 8a 10 80       	push   $0x80108a56
80102b3d:	68 20 22 11 80       	push   $0x80112220
80102b42:	e8 86 27 00 00       	call   801052cd <initlock>
80102b47:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b4a:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
80102b51:	00 00 00 
  freerange(vstart, vend);
80102b54:	83 ec 08             	sub    $0x8,%esp
80102b57:	ff 75 0c             	pushl  0xc(%ebp)
80102b5a:	ff 75 08             	pushl  0x8(%ebp)
80102b5d:	e8 2a 00 00 00       	call   80102b8c <freerange>
80102b62:	83 c4 10             	add    $0x10,%esp
}
80102b65:	90                   	nop
80102b66:	c9                   	leave  
80102b67:	c3                   	ret    

80102b68 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b68:	55                   	push   %ebp
80102b69:	89 e5                	mov    %esp,%ebp
80102b6b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b6e:	83 ec 08             	sub    $0x8,%esp
80102b71:	ff 75 0c             	pushl  0xc(%ebp)
80102b74:	ff 75 08             	pushl  0x8(%ebp)
80102b77:	e8 10 00 00 00       	call   80102b8c <freerange>
80102b7c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b7f:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102b86:	00 00 00 
}
80102b89:	90                   	nop
80102b8a:	c9                   	leave  
80102b8b:	c3                   	ret    

80102b8c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b8c:	55                   	push   %ebp
80102b8d:	89 e5                	mov    %esp,%ebp
80102b8f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b92:	8b 45 08             	mov    0x8(%ebp),%eax
80102b95:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ba2:	eb 15                	jmp    80102bb9 <freerange+0x2d>
    kfree(p);
80102ba4:	83 ec 0c             	sub    $0xc,%esp
80102ba7:	ff 75 f4             	pushl  -0xc(%ebp)
80102baa:	e8 1a 00 00 00       	call   80102bc9 <kfree>
80102baf:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbc:	05 00 10 00 00       	add    $0x1000,%eax
80102bc1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102bc4:	76 de                	jbe    80102ba4 <freerange+0x18>
    kfree(p);
}
80102bc6:	90                   	nop
80102bc7:	c9                   	leave  
80102bc8:	c3                   	ret    

80102bc9 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bc9:	55                   	push   %ebp
80102bca:	89 e5                	mov    %esp,%ebp
80102bcc:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bd7:	85 c0                	test   %eax,%eax
80102bd9:	75 1b                	jne    80102bf6 <kfree+0x2d>
80102bdb:	81 7d 08 3c 56 11 80 	cmpl   $0x8011563c,0x8(%ebp)
80102be2:	72 12                	jb     80102bf6 <kfree+0x2d>
80102be4:	ff 75 08             	pushl  0x8(%ebp)
80102be7:	e8 36 ff ff ff       	call   80102b22 <v2p>
80102bec:	83 c4 04             	add    $0x4,%esp
80102bef:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bf4:	76 0d                	jbe    80102c03 <kfree+0x3a>
    panic("kfree");
80102bf6:	83 ec 0c             	sub    $0xc,%esp
80102bf9:	68 5b 8a 10 80       	push   $0x80108a5b
80102bfe:	e8 63 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c03:	83 ec 04             	sub    $0x4,%esp
80102c06:	68 00 10 00 00       	push   $0x1000
80102c0b:	6a 01                	push   $0x1
80102c0d:	ff 75 08             	pushl  0x8(%ebp)
80102c10:	e8 3d 29 00 00       	call   80105552 <memset>
80102c15:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c18:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c1d:	85 c0                	test   %eax,%eax
80102c1f:	74 10                	je     80102c31 <kfree+0x68>
    acquire(&kmem.lock);
80102c21:	83 ec 0c             	sub    $0xc,%esp
80102c24:	68 20 22 11 80       	push   $0x80112220
80102c29:	e8 c1 26 00 00       	call   801052ef <acquire>
80102c2e:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c31:	8b 45 08             	mov    0x8(%ebp),%eax
80102c34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c37:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c40:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c45:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102c4a:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c4f:	85 c0                	test   %eax,%eax
80102c51:	74 10                	je     80102c63 <kfree+0x9a>
    release(&kmem.lock);
80102c53:	83 ec 0c             	sub    $0xc,%esp
80102c56:	68 20 22 11 80       	push   $0x80112220
80102c5b:	e8 f6 26 00 00       	call   80105356 <release>
80102c60:	83 c4 10             	add    $0x10,%esp
}
80102c63:	90                   	nop
80102c64:	c9                   	leave  
80102c65:	c3                   	ret    

80102c66 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c66:	55                   	push   %ebp
80102c67:	89 e5                	mov    %esp,%ebp
80102c69:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c6c:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c71:	85 c0                	test   %eax,%eax
80102c73:	74 10                	je     80102c85 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c75:	83 ec 0c             	sub    $0xc,%esp
80102c78:	68 20 22 11 80       	push   $0x80112220
80102c7d:	e8 6d 26 00 00       	call   801052ef <acquire>
80102c82:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c85:	a1 58 22 11 80       	mov    0x80112258,%eax
80102c8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c91:	74 0a                	je     80102c9d <kalloc+0x37>
    kmem.freelist = r->next;
80102c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c96:	8b 00                	mov    (%eax),%eax
80102c98:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102c9d:	a1 54 22 11 80       	mov    0x80112254,%eax
80102ca2:	85 c0                	test   %eax,%eax
80102ca4:	74 10                	je     80102cb6 <kalloc+0x50>
    release(&kmem.lock);
80102ca6:	83 ec 0c             	sub    $0xc,%esp
80102ca9:	68 20 22 11 80       	push   $0x80112220
80102cae:	e8 a3 26 00 00       	call   80105356 <release>
80102cb3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cb9:	c9                   	leave  
80102cba:	c3                   	ret    

80102cbb <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cbb:	55                   	push   %ebp
80102cbc:	89 e5                	mov    %esp,%ebp
80102cbe:	83 ec 14             	sub    $0x14,%esp
80102cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cc8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ccc:	89 c2                	mov    %eax,%edx
80102cce:	ec                   	in     (%dx),%al
80102ccf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cd2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cd6:	c9                   	leave  
80102cd7:	c3                   	ret    

80102cd8 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cd8:	55                   	push   %ebp
80102cd9:	89 e5                	mov    %esp,%ebp
80102cdb:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cde:	6a 64                	push   $0x64
80102ce0:	e8 d6 ff ff ff       	call   80102cbb <inb>
80102ce5:	83 c4 04             	add    $0x4,%esp
80102ce8:	0f b6 c0             	movzbl %al,%eax
80102ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf1:	83 e0 01             	and    $0x1,%eax
80102cf4:	85 c0                	test   %eax,%eax
80102cf6:	75 0a                	jne    80102d02 <kbdgetc+0x2a>
    return -1;
80102cf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102cfd:	e9 23 01 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d02:	6a 60                	push   $0x60
80102d04:	e8 b2 ff ff ff       	call   80102cbb <inb>
80102d09:	83 c4 04             	add    $0x4,%esp
80102d0c:	0f b6 c0             	movzbl %al,%eax
80102d0f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d12:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d19:	75 17                	jne    80102d32 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d1b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d20:	83 c8 40             	or     $0x40,%eax
80102d23:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d28:	b8 00 00 00 00       	mov    $0x0,%eax
80102d2d:	e9 f3 00 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d35:	25 80 00 00 00       	and    $0x80,%eax
80102d3a:	85 c0                	test   %eax,%eax
80102d3c:	74 45                	je     80102d83 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d3e:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d43:	83 e0 40             	and    $0x40,%eax
80102d46:	85 c0                	test   %eax,%eax
80102d48:	75 08                	jne    80102d52 <kbdgetc+0x7a>
80102d4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d4d:	83 e0 7f             	and    $0x7f,%eax
80102d50:	eb 03                	jmp    80102d55 <kbdgetc+0x7d>
80102d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d55:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d5b:	05 20 90 10 80       	add    $0x80109020,%eax
80102d60:	0f b6 00             	movzbl (%eax),%eax
80102d63:	83 c8 40             	or     $0x40,%eax
80102d66:	0f b6 c0             	movzbl %al,%eax
80102d69:	f7 d0                	not    %eax
80102d6b:	89 c2                	mov    %eax,%edx
80102d6d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d72:	21 d0                	and    %edx,%eax
80102d74:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d79:	b8 00 00 00 00       	mov    $0x0,%eax
80102d7e:	e9 a2 00 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d83:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d88:	83 e0 40             	and    $0x40,%eax
80102d8b:	85 c0                	test   %eax,%eax
80102d8d:	74 14                	je     80102da3 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d8f:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d96:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d9b:	83 e0 bf             	and    $0xffffffbf,%eax
80102d9e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102da3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da6:	05 20 90 10 80       	add    $0x80109020,%eax
80102dab:	0f b6 00             	movzbl (%eax),%eax
80102dae:	0f b6 d0             	movzbl %al,%edx
80102db1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102db6:	09 d0                	or     %edx,%eax
80102db8:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102dbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc0:	05 20 91 10 80       	add    $0x80109120,%eax
80102dc5:	0f b6 00             	movzbl (%eax),%eax
80102dc8:	0f b6 d0             	movzbl %al,%edx
80102dcb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dd0:	31 d0                	xor    %edx,%eax
80102dd2:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dd7:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ddc:	83 e0 03             	and    $0x3,%eax
80102ddf:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102de6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de9:	01 d0                	add    %edx,%eax
80102deb:	0f b6 00             	movzbl (%eax),%eax
80102dee:	0f b6 c0             	movzbl %al,%eax
80102df1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102df4:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102df9:	83 e0 08             	and    $0x8,%eax
80102dfc:	85 c0                	test   %eax,%eax
80102dfe:	74 22                	je     80102e22 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e00:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e04:	76 0c                	jbe    80102e12 <kbdgetc+0x13a>
80102e06:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e0a:	77 06                	ja     80102e12 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e0c:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e10:	eb 10                	jmp    80102e22 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e12:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e16:	76 0a                	jbe    80102e22 <kbdgetc+0x14a>
80102e18:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e1c:	77 04                	ja     80102e22 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e1e:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e22:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e25:	c9                   	leave  
80102e26:	c3                   	ret    

80102e27 <kbdintr>:

void
kbdintr(void)
{
80102e27:	55                   	push   %ebp
80102e28:	89 e5                	mov    %esp,%ebp
80102e2a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e2d:	83 ec 0c             	sub    $0xc,%esp
80102e30:	68 d8 2c 10 80       	push   $0x80102cd8
80102e35:	e8 bf d9 ff ff       	call   801007f9 <consoleintr>
80102e3a:	83 c4 10             	add    $0x10,%esp
}
80102e3d:	90                   	nop
80102e3e:	c9                   	leave  
80102e3f:	c3                   	ret    

80102e40 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e40:	55                   	push   %ebp
80102e41:	89 e5                	mov    %esp,%ebp
80102e43:	83 ec 14             	sub    $0x14,%esp
80102e46:	8b 45 08             	mov    0x8(%ebp),%eax
80102e49:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e4d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e51:	89 c2                	mov    %eax,%edx
80102e53:	ec                   	in     (%dx),%al
80102e54:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e57:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e5b:	c9                   	leave  
80102e5c:	c3                   	ret    

80102e5d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e5d:	55                   	push   %ebp
80102e5e:	89 e5                	mov    %esp,%ebp
80102e60:	83 ec 08             	sub    $0x8,%esp
80102e63:	8b 55 08             	mov    0x8(%ebp),%edx
80102e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e69:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e6d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e70:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e74:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e78:	ee                   	out    %al,(%dx)
}
80102e79:	90                   	nop
80102e7a:	c9                   	leave  
80102e7b:	c3                   	ret    

80102e7c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e7c:	55                   	push   %ebp
80102e7d:	89 e5                	mov    %esp,%ebp
80102e7f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e82:	9c                   	pushf  
80102e83:	58                   	pop    %eax
80102e84:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e87:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e8a:	c9                   	leave  
80102e8b:	c3                   	ret    

80102e8c <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e8c:	55                   	push   %ebp
80102e8d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e8f:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e94:	8b 55 08             	mov    0x8(%ebp),%edx
80102e97:	c1 e2 02             	shl    $0x2,%edx
80102e9a:	01 c2                	add    %eax,%edx
80102e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e9f:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ea1:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ea6:	83 c0 20             	add    $0x20,%eax
80102ea9:	8b 00                	mov    (%eax),%eax
}
80102eab:	90                   	nop
80102eac:	5d                   	pop    %ebp
80102ead:	c3                   	ret    

80102eae <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102eb1:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	0f 84 0b 01 00 00    	je     80102fc9 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ebe:	68 3f 01 00 00       	push   $0x13f
80102ec3:	6a 3c                	push   $0x3c
80102ec5:	e8 c2 ff ff ff       	call   80102e8c <lapicw>
80102eca:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ecd:	6a 0b                	push   $0xb
80102ecf:	68 f8 00 00 00       	push   $0xf8
80102ed4:	e8 b3 ff ff ff       	call   80102e8c <lapicw>
80102ed9:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102edc:	68 20 00 02 00       	push   $0x20020
80102ee1:	68 c8 00 00 00       	push   $0xc8
80102ee6:	e8 a1 ff ff ff       	call   80102e8c <lapicw>
80102eeb:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102eee:	68 80 96 98 00       	push   $0x989680
80102ef3:	68 e0 00 00 00       	push   $0xe0
80102ef8:	e8 8f ff ff ff       	call   80102e8c <lapicw>
80102efd:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f00:	68 00 00 01 00       	push   $0x10000
80102f05:	68 d4 00 00 00       	push   $0xd4
80102f0a:	e8 7d ff ff ff       	call   80102e8c <lapicw>
80102f0f:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f12:	68 00 00 01 00       	push   $0x10000
80102f17:	68 d8 00 00 00       	push   $0xd8
80102f1c:	e8 6b ff ff ff       	call   80102e8c <lapicw>
80102f21:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f24:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f29:	83 c0 30             	add    $0x30,%eax
80102f2c:	8b 00                	mov    (%eax),%eax
80102f2e:	c1 e8 10             	shr    $0x10,%eax
80102f31:	0f b6 c0             	movzbl %al,%eax
80102f34:	83 f8 03             	cmp    $0x3,%eax
80102f37:	76 12                	jbe    80102f4b <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f39:	68 00 00 01 00       	push   $0x10000
80102f3e:	68 d0 00 00 00       	push   $0xd0
80102f43:	e8 44 ff ff ff       	call   80102e8c <lapicw>
80102f48:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f4b:	6a 33                	push   $0x33
80102f4d:	68 dc 00 00 00       	push   $0xdc
80102f52:	e8 35 ff ff ff       	call   80102e8c <lapicw>
80102f57:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f5a:	6a 00                	push   $0x0
80102f5c:	68 a0 00 00 00       	push   $0xa0
80102f61:	e8 26 ff ff ff       	call   80102e8c <lapicw>
80102f66:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f69:	6a 00                	push   $0x0
80102f6b:	68 a0 00 00 00       	push   $0xa0
80102f70:	e8 17 ff ff ff       	call   80102e8c <lapicw>
80102f75:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f78:	6a 00                	push   $0x0
80102f7a:	6a 2c                	push   $0x2c
80102f7c:	e8 0b ff ff ff       	call   80102e8c <lapicw>
80102f81:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f84:	6a 00                	push   $0x0
80102f86:	68 c4 00 00 00       	push   $0xc4
80102f8b:	e8 fc fe ff ff       	call   80102e8c <lapicw>
80102f90:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f93:	68 00 85 08 00       	push   $0x88500
80102f98:	68 c0 00 00 00       	push   $0xc0
80102f9d:	e8 ea fe ff ff       	call   80102e8c <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fa5:	90                   	nop
80102fa6:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102fab:	05 00 03 00 00       	add    $0x300,%eax
80102fb0:	8b 00                	mov    (%eax),%eax
80102fb2:	25 00 10 00 00       	and    $0x1000,%eax
80102fb7:	85 c0                	test   %eax,%eax
80102fb9:	75 eb                	jne    80102fa6 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fbb:	6a 00                	push   $0x0
80102fbd:	6a 20                	push   $0x20
80102fbf:	e8 c8 fe ff ff       	call   80102e8c <lapicw>
80102fc4:	83 c4 08             	add    $0x8,%esp
80102fc7:	eb 01                	jmp    80102fca <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102fc9:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102fca:	c9                   	leave  
80102fcb:	c3                   	ret    

80102fcc <cpunum>:

int
cpunum(void)
{
80102fcc:	55                   	push   %ebp
80102fcd:	89 e5                	mov    %esp,%ebp
80102fcf:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fd2:	e8 a5 fe ff ff       	call   80102e7c <readeflags>
80102fd7:	25 00 02 00 00       	and    $0x200,%eax
80102fdc:	85 c0                	test   %eax,%eax
80102fde:	74 26                	je     80103006 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102fe0:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102fe5:	8d 50 01             	lea    0x1(%eax),%edx
80102fe8:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102fee:	85 c0                	test   %eax,%eax
80102ff0:	75 14                	jne    80103006 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102ff2:	8b 45 04             	mov    0x4(%ebp),%eax
80102ff5:	83 ec 08             	sub    $0x8,%esp
80102ff8:	50                   	push   %eax
80102ff9:	68 64 8a 10 80       	push   $0x80108a64
80102ffe:	e8 c3 d3 ff ff       	call   801003c6 <cprintf>
80103003:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103006:	a1 5c 22 11 80       	mov    0x8011225c,%eax
8010300b:	85 c0                	test   %eax,%eax
8010300d:	74 0f                	je     8010301e <cpunum+0x52>
    return lapic[ID]>>24;
8010300f:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80103014:	83 c0 20             	add    $0x20,%eax
80103017:	8b 00                	mov    (%eax),%eax
80103019:	c1 e8 18             	shr    $0x18,%eax
8010301c:	eb 05                	jmp    80103023 <cpunum+0x57>
  return 0;
8010301e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103023:	c9                   	leave  
80103024:	c3                   	ret    

80103025 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103025:	55                   	push   %ebp
80103026:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103028:	a1 5c 22 11 80       	mov    0x8011225c,%eax
8010302d:	85 c0                	test   %eax,%eax
8010302f:	74 0c                	je     8010303d <lapiceoi+0x18>
    lapicw(EOI, 0);
80103031:	6a 00                	push   $0x0
80103033:	6a 2c                	push   $0x2c
80103035:	e8 52 fe ff ff       	call   80102e8c <lapicw>
8010303a:	83 c4 08             	add    $0x8,%esp
}
8010303d:	90                   	nop
8010303e:	c9                   	leave  
8010303f:	c3                   	ret    

80103040 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103040:	55                   	push   %ebp
80103041:	89 e5                	mov    %esp,%ebp
}
80103043:	90                   	nop
80103044:	5d                   	pop    %ebp
80103045:	c3                   	ret    

80103046 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103046:	55                   	push   %ebp
80103047:	89 e5                	mov    %esp,%ebp
80103049:	83 ec 14             	sub    $0x14,%esp
8010304c:	8b 45 08             	mov    0x8(%ebp),%eax
8010304f:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103052:	6a 0f                	push   $0xf
80103054:	6a 70                	push   $0x70
80103056:	e8 02 fe ff ff       	call   80102e5d <outb>
8010305b:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010305e:	6a 0a                	push   $0xa
80103060:	6a 71                	push   $0x71
80103062:	e8 f6 fd ff ff       	call   80102e5d <outb>
80103067:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010306a:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103071:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103074:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103079:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010307c:	83 c0 02             	add    $0x2,%eax
8010307f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103082:	c1 ea 04             	shr    $0x4,%edx
80103085:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103088:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010308c:	c1 e0 18             	shl    $0x18,%eax
8010308f:	50                   	push   %eax
80103090:	68 c4 00 00 00       	push   $0xc4
80103095:	e8 f2 fd ff ff       	call   80102e8c <lapicw>
8010309a:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010309d:	68 00 c5 00 00       	push   $0xc500
801030a2:	68 c0 00 00 00       	push   $0xc0
801030a7:	e8 e0 fd ff ff       	call   80102e8c <lapicw>
801030ac:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030af:	68 c8 00 00 00       	push   $0xc8
801030b4:	e8 87 ff ff ff       	call   80103040 <microdelay>
801030b9:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030bc:	68 00 85 00 00       	push   $0x8500
801030c1:	68 c0 00 00 00       	push   $0xc0
801030c6:	e8 c1 fd ff ff       	call   80102e8c <lapicw>
801030cb:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ce:	6a 64                	push   $0x64
801030d0:	e8 6b ff ff ff       	call   80103040 <microdelay>
801030d5:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030df:	eb 3d                	jmp    8010311e <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030e1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030e5:	c1 e0 18             	shl    $0x18,%eax
801030e8:	50                   	push   %eax
801030e9:	68 c4 00 00 00       	push   $0xc4
801030ee:	e8 99 fd ff ff       	call   80102e8c <lapicw>
801030f3:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801030f9:	c1 e8 0c             	shr    $0xc,%eax
801030fc:	80 cc 06             	or     $0x6,%ah
801030ff:	50                   	push   %eax
80103100:	68 c0 00 00 00       	push   $0xc0
80103105:	e8 82 fd ff ff       	call   80102e8c <lapicw>
8010310a:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010310d:	68 c8 00 00 00       	push   $0xc8
80103112:	e8 29 ff ff ff       	call   80103040 <microdelay>
80103117:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010311a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010311e:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103122:	7e bd                	jle    801030e1 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103124:	90                   	nop
80103125:	c9                   	leave  
80103126:	c3                   	ret    

80103127 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103127:	55                   	push   %ebp
80103128:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010312a:	8b 45 08             	mov    0x8(%ebp),%eax
8010312d:	0f b6 c0             	movzbl %al,%eax
80103130:	50                   	push   %eax
80103131:	6a 70                	push   $0x70
80103133:	e8 25 fd ff ff       	call   80102e5d <outb>
80103138:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010313b:	68 c8 00 00 00       	push   $0xc8
80103140:	e8 fb fe ff ff       	call   80103040 <microdelay>
80103145:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103148:	6a 71                	push   $0x71
8010314a:	e8 f1 fc ff ff       	call   80102e40 <inb>
8010314f:	83 c4 04             	add    $0x4,%esp
80103152:	0f b6 c0             	movzbl %al,%eax
}
80103155:	c9                   	leave  
80103156:	c3                   	ret    

80103157 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103157:	55                   	push   %ebp
80103158:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010315a:	6a 00                	push   $0x0
8010315c:	e8 c6 ff ff ff       	call   80103127 <cmos_read>
80103161:	83 c4 04             	add    $0x4,%esp
80103164:	89 c2                	mov    %eax,%edx
80103166:	8b 45 08             	mov    0x8(%ebp),%eax
80103169:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010316b:	6a 02                	push   $0x2
8010316d:	e8 b5 ff ff ff       	call   80103127 <cmos_read>
80103172:	83 c4 04             	add    $0x4,%esp
80103175:	89 c2                	mov    %eax,%edx
80103177:	8b 45 08             	mov    0x8(%ebp),%eax
8010317a:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010317d:	6a 04                	push   $0x4
8010317f:	e8 a3 ff ff ff       	call   80103127 <cmos_read>
80103184:	83 c4 04             	add    $0x4,%esp
80103187:	89 c2                	mov    %eax,%edx
80103189:	8b 45 08             	mov    0x8(%ebp),%eax
8010318c:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010318f:	6a 07                	push   $0x7
80103191:	e8 91 ff ff ff       	call   80103127 <cmos_read>
80103196:	83 c4 04             	add    $0x4,%esp
80103199:	89 c2                	mov    %eax,%edx
8010319b:	8b 45 08             	mov    0x8(%ebp),%eax
8010319e:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031a1:	6a 08                	push   $0x8
801031a3:	e8 7f ff ff ff       	call   80103127 <cmos_read>
801031a8:	83 c4 04             	add    $0x4,%esp
801031ab:	89 c2                	mov    %eax,%edx
801031ad:	8b 45 08             	mov    0x8(%ebp),%eax
801031b0:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031b3:	6a 09                	push   $0x9
801031b5:	e8 6d ff ff ff       	call   80103127 <cmos_read>
801031ba:	83 c4 04             	add    $0x4,%esp
801031bd:	89 c2                	mov    %eax,%edx
801031bf:	8b 45 08             	mov    0x8(%ebp),%eax
801031c2:	89 50 14             	mov    %edx,0x14(%eax)
}
801031c5:	90                   	nop
801031c6:	c9                   	leave  
801031c7:	c3                   	ret    

801031c8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031c8:	55                   	push   %ebp
801031c9:	89 e5                	mov    %esp,%ebp
801031cb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031ce:	6a 0b                	push   $0xb
801031d0:	e8 52 ff ff ff       	call   80103127 <cmos_read>
801031d5:	83 c4 04             	add    $0x4,%esp
801031d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031de:	83 e0 04             	and    $0x4,%eax
801031e1:	85 c0                	test   %eax,%eax
801031e3:	0f 94 c0             	sete   %al
801031e6:	0f b6 c0             	movzbl %al,%eax
801031e9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031ef:	50                   	push   %eax
801031f0:	e8 62 ff ff ff       	call   80103157 <fill_rtcdate>
801031f5:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801031f8:	6a 0a                	push   $0xa
801031fa:	e8 28 ff ff ff       	call   80103127 <cmos_read>
801031ff:	83 c4 04             	add    $0x4,%esp
80103202:	25 80 00 00 00       	and    $0x80,%eax
80103207:	85 c0                	test   %eax,%eax
80103209:	75 27                	jne    80103232 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010320b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010320e:	50                   	push   %eax
8010320f:	e8 43 ff ff ff       	call   80103157 <fill_rtcdate>
80103214:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103217:	83 ec 04             	sub    $0x4,%esp
8010321a:	6a 18                	push   $0x18
8010321c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010321f:	50                   	push   %eax
80103220:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103223:	50                   	push   %eax
80103224:	e8 90 23 00 00       	call   801055b9 <memcmp>
80103229:	83 c4 10             	add    $0x10,%esp
8010322c:	85 c0                	test   %eax,%eax
8010322e:	74 05                	je     80103235 <cmostime+0x6d>
80103230:	eb ba                	jmp    801031ec <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103232:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103233:	eb b7                	jmp    801031ec <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103235:	90                   	nop
  }

  // convert
  if (bcd) {
80103236:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010323a:	0f 84 b4 00 00 00    	je     801032f4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103240:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103243:	c1 e8 04             	shr    $0x4,%eax
80103246:	89 c2                	mov    %eax,%edx
80103248:	89 d0                	mov    %edx,%eax
8010324a:	c1 e0 02             	shl    $0x2,%eax
8010324d:	01 d0                	add    %edx,%eax
8010324f:	01 c0                	add    %eax,%eax
80103251:	89 c2                	mov    %eax,%edx
80103253:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103256:	83 e0 0f             	and    $0xf,%eax
80103259:	01 d0                	add    %edx,%eax
8010325b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010325e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103261:	c1 e8 04             	shr    $0x4,%eax
80103264:	89 c2                	mov    %eax,%edx
80103266:	89 d0                	mov    %edx,%eax
80103268:	c1 e0 02             	shl    $0x2,%eax
8010326b:	01 d0                	add    %edx,%eax
8010326d:	01 c0                	add    %eax,%eax
8010326f:	89 c2                	mov    %eax,%edx
80103271:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103274:	83 e0 0f             	and    $0xf,%eax
80103277:	01 d0                	add    %edx,%eax
80103279:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010327c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010327f:	c1 e8 04             	shr    $0x4,%eax
80103282:	89 c2                	mov    %eax,%edx
80103284:	89 d0                	mov    %edx,%eax
80103286:	c1 e0 02             	shl    $0x2,%eax
80103289:	01 d0                	add    %edx,%eax
8010328b:	01 c0                	add    %eax,%eax
8010328d:	89 c2                	mov    %eax,%edx
8010328f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103292:	83 e0 0f             	and    $0xf,%eax
80103295:	01 d0                	add    %edx,%eax
80103297:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010329a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010329d:	c1 e8 04             	shr    $0x4,%eax
801032a0:	89 c2                	mov    %eax,%edx
801032a2:	89 d0                	mov    %edx,%eax
801032a4:	c1 e0 02             	shl    $0x2,%eax
801032a7:	01 d0                	add    %edx,%eax
801032a9:	01 c0                	add    %eax,%eax
801032ab:	89 c2                	mov    %eax,%edx
801032ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b0:	83 e0 0f             	and    $0xf,%eax
801032b3:	01 d0                	add    %edx,%eax
801032b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032bb:	c1 e8 04             	shr    $0x4,%eax
801032be:	89 c2                	mov    %eax,%edx
801032c0:	89 d0                	mov    %edx,%eax
801032c2:	c1 e0 02             	shl    $0x2,%eax
801032c5:	01 d0                	add    %edx,%eax
801032c7:	01 c0                	add    %eax,%eax
801032c9:	89 c2                	mov    %eax,%edx
801032cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ce:	83 e0 0f             	and    $0xf,%eax
801032d1:	01 d0                	add    %edx,%eax
801032d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d9:	c1 e8 04             	shr    $0x4,%eax
801032dc:	89 c2                	mov    %eax,%edx
801032de:	89 d0                	mov    %edx,%eax
801032e0:	c1 e0 02             	shl    $0x2,%eax
801032e3:	01 d0                	add    %edx,%eax
801032e5:	01 c0                	add    %eax,%eax
801032e7:	89 c2                	mov    %eax,%edx
801032e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ec:	83 e0 0f             	and    $0xf,%eax
801032ef:	01 d0                	add    %edx,%eax
801032f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032f4:	8b 45 08             	mov    0x8(%ebp),%eax
801032f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032fa:	89 10                	mov    %edx,(%eax)
801032fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032ff:	89 50 04             	mov    %edx,0x4(%eax)
80103302:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103305:	89 50 08             	mov    %edx,0x8(%eax)
80103308:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010330b:	89 50 0c             	mov    %edx,0xc(%eax)
8010330e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103311:	89 50 10             	mov    %edx,0x10(%eax)
80103314:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103317:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010331a:	8b 45 08             	mov    0x8(%ebp),%eax
8010331d:	8b 40 14             	mov    0x14(%eax),%eax
80103320:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103326:	8b 45 08             	mov    0x8(%ebp),%eax
80103329:	89 50 14             	mov    %edx,0x14(%eax)
}
8010332c:	90                   	nop
8010332d:	c9                   	leave  
8010332e:	c3                   	ret    

8010332f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010332f:	55                   	push   %ebp
80103330:	89 e5                	mov    %esp,%ebp
80103332:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103335:	83 ec 08             	sub    $0x8,%esp
80103338:	68 90 8a 10 80       	push   $0x80108a90
8010333d:	68 60 22 11 80       	push   $0x80112260
80103342:	e8 86 1f 00 00       	call   801052cd <initlock>
80103347:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010334a:	83 ec 08             	sub    $0x8,%esp
8010334d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103350:	50                   	push   %eax
80103351:	ff 75 08             	pushl  0x8(%ebp)
80103354:	e8 2b e0 ff ff       	call   80101384 <readsb>
80103359:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010335c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010335f:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
80103364:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103367:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = dev;
8010336c:	8b 45 08             	mov    0x8(%ebp),%eax
8010336f:	a3 a4 22 11 80       	mov    %eax,0x801122a4
  recover_from_log();
80103374:	e8 b2 01 00 00       	call   8010352b <recover_from_log>
}
80103379:	90                   	nop
8010337a:	c9                   	leave  
8010337b:	c3                   	ret    

8010337c <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010337c:	55                   	push   %ebp
8010337d:	89 e5                	mov    %esp,%ebp
8010337f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103389:	e9 95 00 00 00       	jmp    80103423 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010338e:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103397:	01 d0                	add    %edx,%eax
80103399:	83 c0 01             	add    $0x1,%eax
8010339c:	89 c2                	mov    %eax,%edx
8010339e:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033a3:	83 ec 08             	sub    $0x8,%esp
801033a6:	52                   	push   %edx
801033a7:	50                   	push   %eax
801033a8:	e8 09 ce ff ff       	call   801001b6 <bread>
801033ad:	83 c4 10             	add    $0x10,%esp
801033b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b6:	83 c0 10             	add    $0x10,%eax
801033b9:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801033c0:	89 c2                	mov    %eax,%edx
801033c2:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033c7:	83 ec 08             	sub    $0x8,%esp
801033ca:	52                   	push   %edx
801033cb:	50                   	push   %eax
801033cc:	e8 e5 cd ff ff       	call   801001b6 <bread>
801033d1:	83 c4 10             	add    $0x10,%esp
801033d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033da:	8d 50 18             	lea    0x18(%eax),%edx
801033dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e0:	83 c0 18             	add    $0x18,%eax
801033e3:	83 ec 04             	sub    $0x4,%esp
801033e6:	68 00 02 00 00       	push   $0x200
801033eb:	52                   	push   %edx
801033ec:	50                   	push   %eax
801033ed:	e8 1f 22 00 00       	call   80105611 <memmove>
801033f2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	ff 75 ec             	pushl  -0x14(%ebp)
801033fb:	e8 ef cd ff ff       	call   801001ef <bwrite>
80103400:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	ff 75 f0             	pushl  -0x10(%ebp)
80103409:	e8 20 ce ff ff       	call   8010022e <brelse>
8010340e:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103411:	83 ec 0c             	sub    $0xc,%esp
80103414:	ff 75 ec             	pushl  -0x14(%ebp)
80103417:	e8 12 ce ff ff       	call   8010022e <brelse>
8010341c:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010341f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103423:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103428:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010342b:	0f 8f 5d ff ff ff    	jg     8010338e <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103431:	90                   	nop
80103432:	c9                   	leave  
80103433:	c3                   	ret    

80103434 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103434:	55                   	push   %ebp
80103435:	89 e5                	mov    %esp,%ebp
80103437:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010343a:	a1 94 22 11 80       	mov    0x80112294,%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103446:	83 ec 08             	sub    $0x8,%esp
80103449:	52                   	push   %edx
8010344a:	50                   	push   %eax
8010344b:	e8 66 cd ff ff       	call   801001b6 <bread>
80103450:	83 c4 10             	add    $0x10,%esp
80103453:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103456:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103459:	83 c0 18             	add    $0x18,%eax
8010345c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010345f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103462:	8b 00                	mov    (%eax),%eax
80103464:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
80103469:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103470:	eb 1b                	jmp    8010348d <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103475:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103478:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010347c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010347f:	83 c2 10             	add    $0x10,%edx
80103482:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103489:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010348d:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103492:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103495:	7f db                	jg     80103472 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103497:	83 ec 0c             	sub    $0xc,%esp
8010349a:	ff 75 f0             	pushl  -0x10(%ebp)
8010349d:	e8 8c cd ff ff       	call   8010022e <brelse>
801034a2:	83 c4 10             	add    $0x10,%esp
}
801034a5:	90                   	nop
801034a6:	c9                   	leave  
801034a7:	c3                   	ret    

801034a8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034a8:	55                   	push   %ebp
801034a9:	89 e5                	mov    %esp,%ebp
801034ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ae:	a1 94 22 11 80       	mov    0x80112294,%eax
801034b3:	89 c2                	mov    %eax,%edx
801034b5:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801034ba:	83 ec 08             	sub    $0x8,%esp
801034bd:	52                   	push   %edx
801034be:	50                   	push   %eax
801034bf:	e8 f2 cc ff ff       	call   801001b6 <bread>
801034c4:	83 c4 10             	add    $0x10,%esp
801034c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cd:	83 c0 18             	add    $0x18,%eax
801034d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034d3:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
801034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e5:	eb 1b                	jmp    80103502 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ea:	83 c0 10             	add    $0x10,%eax
801034ed:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
801034f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034fa:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103502:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103507:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010350a:	7f db                	jg     801034e7 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010350c:	83 ec 0c             	sub    $0xc,%esp
8010350f:	ff 75 f0             	pushl  -0x10(%ebp)
80103512:	e8 d8 cc ff ff       	call   801001ef <bwrite>
80103517:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010351a:	83 ec 0c             	sub    $0xc,%esp
8010351d:	ff 75 f0             	pushl  -0x10(%ebp)
80103520:	e8 09 cd ff ff       	call   8010022e <brelse>
80103525:	83 c4 10             	add    $0x10,%esp
}
80103528:	90                   	nop
80103529:	c9                   	leave  
8010352a:	c3                   	ret    

8010352b <recover_from_log>:

static void
recover_from_log(void)
{
8010352b:	55                   	push   %ebp
8010352c:	89 e5                	mov    %esp,%ebp
8010352e:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103531:	e8 fe fe ff ff       	call   80103434 <read_head>
  install_trans(); // if committed, copy from log to disk
80103536:	e8 41 fe ff ff       	call   8010337c <install_trans>
  log.lh.n = 0;
8010353b:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103542:	00 00 00 
  write_head(); // clear the log
80103545:	e8 5e ff ff ff       	call   801034a8 <write_head>
}
8010354a:	90                   	nop
8010354b:	c9                   	leave  
8010354c:	c3                   	ret    

8010354d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010354d:	55                   	push   %ebp
8010354e:	89 e5                	mov    %esp,%ebp
80103550:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103553:	83 ec 0c             	sub    $0xc,%esp
80103556:	68 60 22 11 80       	push   $0x80112260
8010355b:	e8 8f 1d 00 00       	call   801052ef <acquire>
80103560:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103563:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103568:	85 c0                	test   %eax,%eax
8010356a:	74 17                	je     80103583 <begin_op+0x36>
      sleep(&log, &log.lock);
8010356c:	83 ec 08             	sub    $0x8,%esp
8010356f:	68 60 22 11 80       	push   $0x80112260
80103574:	68 60 22 11 80       	push   $0x80112260
80103579:	e8 6f 1a 00 00       	call   80104fed <sleep>
8010357e:	83 c4 10             	add    $0x10,%esp
80103581:	eb e0                	jmp    80103563 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103583:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103589:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010358e:	8d 50 01             	lea    0x1(%eax),%edx
80103591:	89 d0                	mov    %edx,%eax
80103593:	c1 e0 02             	shl    $0x2,%eax
80103596:	01 d0                	add    %edx,%eax
80103598:	01 c0                	add    %eax,%eax
8010359a:	01 c8                	add    %ecx,%eax
8010359c:	83 f8 1e             	cmp    $0x1e,%eax
8010359f:	7e 17                	jle    801035b8 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035a1:	83 ec 08             	sub    $0x8,%esp
801035a4:	68 60 22 11 80       	push   $0x80112260
801035a9:	68 60 22 11 80       	push   $0x80112260
801035ae:	e8 3a 1a 00 00       	call   80104fed <sleep>
801035b3:	83 c4 10             	add    $0x10,%esp
801035b6:	eb ab                	jmp    80103563 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035b8:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801035bd:	83 c0 01             	add    $0x1,%eax
801035c0:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
801035c5:	83 ec 0c             	sub    $0xc,%esp
801035c8:	68 60 22 11 80       	push   $0x80112260
801035cd:	e8 84 1d 00 00       	call   80105356 <release>
801035d2:	83 c4 10             	add    $0x10,%esp
      break;
801035d5:	90                   	nop
    }
  }
}
801035d6:	90                   	nop
801035d7:	c9                   	leave  
801035d8:	c3                   	ret    

801035d9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035d9:	55                   	push   %ebp
801035da:	89 e5                	mov    %esp,%ebp
801035dc:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035e6:	83 ec 0c             	sub    $0xc,%esp
801035e9:	68 60 22 11 80       	push   $0x80112260
801035ee:	e8 fc 1c 00 00       	call   801052ef <acquire>
801035f3:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035f6:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801035fb:	83 e8 01             	sub    $0x1,%eax
801035fe:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
80103603:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103608:	85 c0                	test   %eax,%eax
8010360a:	74 0d                	je     80103619 <end_op+0x40>
    panic("log.committing");
8010360c:	83 ec 0c             	sub    $0xc,%esp
8010360f:	68 94 8a 10 80       	push   $0x80108a94
80103614:	e8 4d cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103619:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010361e:	85 c0                	test   %eax,%eax
80103620:	75 13                	jne    80103635 <end_op+0x5c>
    do_commit = 1;
80103622:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103629:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
80103630:	00 00 00 
80103633:	eb 10                	jmp    80103645 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 60 22 11 80       	push   $0x80112260
8010363d:	e8 99 1a 00 00       	call   801050db <wakeup>
80103642:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103645:	83 ec 0c             	sub    $0xc,%esp
80103648:	68 60 22 11 80       	push   $0x80112260
8010364d:	e8 04 1d 00 00       	call   80105356 <release>
80103652:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103655:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103659:	74 3f                	je     8010369a <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010365b:	e8 f5 00 00 00       	call   80103755 <commit>
    acquire(&log.lock);
80103660:	83 ec 0c             	sub    $0xc,%esp
80103663:	68 60 22 11 80       	push   $0x80112260
80103668:	e8 82 1c 00 00       	call   801052ef <acquire>
8010366d:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103670:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
80103677:	00 00 00 
    wakeup(&log);
8010367a:	83 ec 0c             	sub    $0xc,%esp
8010367d:	68 60 22 11 80       	push   $0x80112260
80103682:	e8 54 1a 00 00       	call   801050db <wakeup>
80103687:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010368a:	83 ec 0c             	sub    $0xc,%esp
8010368d:	68 60 22 11 80       	push   $0x80112260
80103692:	e8 bf 1c 00 00       	call   80105356 <release>
80103697:	83 c4 10             	add    $0x10,%esp
  }
}
8010369a:	90                   	nop
8010369b:	c9                   	leave  
8010369c:	c3                   	ret    

8010369d <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010369d:	55                   	push   %ebp
8010369e:	89 e5                	mov    %esp,%ebp
801036a0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036aa:	e9 95 00 00 00       	jmp    80103744 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036af:	8b 15 94 22 11 80    	mov    0x80112294,%edx
801036b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b8:	01 d0                	add    %edx,%eax
801036ba:	83 c0 01             	add    $0x1,%eax
801036bd:	89 c2                	mov    %eax,%edx
801036bf:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801036c4:	83 ec 08             	sub    $0x8,%esp
801036c7:	52                   	push   %edx
801036c8:	50                   	push   %eax
801036c9:	e8 e8 ca ff ff       	call   801001b6 <bread>
801036ce:	83 c4 10             	add    $0x10,%esp
801036d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d7:	83 c0 10             	add    $0x10,%eax
801036da:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801036e1:	89 c2                	mov    %eax,%edx
801036e3:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801036e8:	83 ec 08             	sub    $0x8,%esp
801036eb:	52                   	push   %edx
801036ec:	50                   	push   %eax
801036ed:	e8 c4 ca ff ff       	call   801001b6 <bread>
801036f2:	83 c4 10             	add    $0x10,%esp
801036f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036fb:	8d 50 18             	lea    0x18(%eax),%edx
801036fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103701:	83 c0 18             	add    $0x18,%eax
80103704:	83 ec 04             	sub    $0x4,%esp
80103707:	68 00 02 00 00       	push   $0x200
8010370c:	52                   	push   %edx
8010370d:	50                   	push   %eax
8010370e:	e8 fe 1e 00 00       	call   80105611 <memmove>
80103713:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103716:	83 ec 0c             	sub    $0xc,%esp
80103719:	ff 75 f0             	pushl  -0x10(%ebp)
8010371c:	e8 ce ca ff ff       	call   801001ef <bwrite>
80103721:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103724:	83 ec 0c             	sub    $0xc,%esp
80103727:	ff 75 ec             	pushl  -0x14(%ebp)
8010372a:	e8 ff ca ff ff       	call   8010022e <brelse>
8010372f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103732:	83 ec 0c             	sub    $0xc,%esp
80103735:	ff 75 f0             	pushl  -0x10(%ebp)
80103738:	e8 f1 ca ff ff       	call   8010022e <brelse>
8010373d:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103740:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103744:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103749:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010374c:	0f 8f 5d ff ff ff    	jg     801036af <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103752:	90                   	nop
80103753:	c9                   	leave  
80103754:	c3                   	ret    

80103755 <commit>:

static void
commit()
{
80103755:	55                   	push   %ebp
80103756:	89 e5                	mov    %esp,%ebp
80103758:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010375b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103760:	85 c0                	test   %eax,%eax
80103762:	7e 1e                	jle    80103782 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103764:	e8 34 ff ff ff       	call   8010369d <write_log>
    write_head();    // Write header to disk -- the real commit
80103769:	e8 3a fd ff ff       	call   801034a8 <write_head>
    install_trans(); // Now install writes to home locations
8010376e:	e8 09 fc ff ff       	call   8010337c <install_trans>
    log.lh.n = 0; 
80103773:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
8010377a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010377d:	e8 26 fd ff ff       	call   801034a8 <write_head>
  }
}
80103782:	90                   	nop
80103783:	c9                   	leave  
80103784:	c3                   	ret    

80103785 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103785:	55                   	push   %ebp
80103786:	89 e5                	mov    %esp,%ebp
80103788:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010378b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103790:	83 f8 1d             	cmp    $0x1d,%eax
80103793:	7f 12                	jg     801037a7 <log_write+0x22>
80103795:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010379a:	8b 15 98 22 11 80    	mov    0x80112298,%edx
801037a0:	83 ea 01             	sub    $0x1,%edx
801037a3:	39 d0                	cmp    %edx,%eax
801037a5:	7c 0d                	jl     801037b4 <log_write+0x2f>
    panic("too big a transaction");
801037a7:	83 ec 0c             	sub    $0xc,%esp
801037aa:	68 a3 8a 10 80       	push   $0x80108aa3
801037af:	e8 b2 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
801037b4:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801037b9:	85 c0                	test   %eax,%eax
801037bb:	7f 0d                	jg     801037ca <log_write+0x45>
    panic("log_write outside of trans");
801037bd:	83 ec 0c             	sub    $0xc,%esp
801037c0:	68 b9 8a 10 80       	push   $0x80108ab9
801037c5:	e8 9c cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
801037ca:	83 ec 0c             	sub    $0xc,%esp
801037cd:	68 60 22 11 80       	push   $0x80112260
801037d2:	e8 18 1b 00 00       	call   801052ef <acquire>
801037d7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037e1:	eb 1d                	jmp    80103800 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e6:	83 c0 10             	add    $0x10,%eax
801037e9:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801037f0:	89 c2                	mov    %eax,%edx
801037f2:	8b 45 08             	mov    0x8(%ebp),%eax
801037f5:	8b 40 08             	mov    0x8(%eax),%eax
801037f8:	39 c2                	cmp    %eax,%edx
801037fa:	74 10                	je     8010380c <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103800:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103805:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103808:	7f d9                	jg     801037e3 <log_write+0x5e>
8010380a:	eb 01                	jmp    8010380d <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
8010380c:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 40 08             	mov    0x8(%eax),%eax
80103813:	89 c2                	mov    %eax,%edx
80103815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103818:	83 c0 10             	add    $0x10,%eax
8010381b:	89 14 85 6c 22 11 80 	mov    %edx,-0x7feedd94(,%eax,4)
  if (i == log.lh.n)
80103822:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103827:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010382a:	75 0d                	jne    80103839 <log_write+0xb4>
    log.lh.n++;
8010382c:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103831:	83 c0 01             	add    $0x1,%eax
80103834:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
80103839:	8b 45 08             	mov    0x8(%ebp),%eax
8010383c:	8b 00                	mov    (%eax),%eax
8010383e:	83 c8 04             	or     $0x4,%eax
80103841:	89 c2                	mov    %eax,%edx
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103848:	83 ec 0c             	sub    $0xc,%esp
8010384b:	68 60 22 11 80       	push   $0x80112260
80103850:	e8 01 1b 00 00       	call   80105356 <release>
80103855:	83 c4 10             	add    $0x10,%esp
}
80103858:	90                   	nop
80103859:	c9                   	leave  
8010385a:	c3                   	ret    

8010385b <v2p>:
8010385b:	55                   	push   %ebp
8010385c:	89 e5                	mov    %esp,%ebp
8010385e:	8b 45 08             	mov    0x8(%ebp),%eax
80103861:	05 00 00 00 80       	add    $0x80000000,%eax
80103866:	5d                   	pop    %ebp
80103867:	c3                   	ret    

80103868 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103868:	55                   	push   %ebp
80103869:	89 e5                	mov    %esp,%ebp
8010386b:	8b 45 08             	mov    0x8(%ebp),%eax
8010386e:	05 00 00 00 80       	add    $0x80000000,%eax
80103873:	5d                   	pop    %ebp
80103874:	c3                   	ret    

80103875 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103875:	55                   	push   %ebp
80103876:	89 e5                	mov    %esp,%ebp
80103878:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010387b:	8b 55 08             	mov    0x8(%ebp),%edx
8010387e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103881:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103884:	f0 87 02             	lock xchg %eax,(%edx)
80103887:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010388a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010388d:	c9                   	leave  
8010388e:	c3                   	ret    

8010388f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010388f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103893:	83 e4 f0             	and    $0xfffffff0,%esp
80103896:	ff 71 fc             	pushl  -0x4(%ecx)
80103899:	55                   	push   %ebp
8010389a:	89 e5                	mov    %esp,%ebp
8010389c:	51                   	push   %ecx
8010389d:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038a0:	83 ec 08             	sub    $0x8,%esp
801038a3:	68 00 00 40 80       	push   $0x80400000
801038a8:	68 3c 56 11 80       	push   $0x8011563c
801038ad:	e8 7d f2 ff ff       	call   80102b2f <kinit1>
801038b2:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038b5:	e8 e9 47 00 00       	call   801080a3 <kvmalloc>
  mpinit();        // collect info about this machine
801038ba:	e8 43 04 00 00       	call   80103d02 <mpinit>
  lapicinit();
801038bf:	e8 ea f5 ff ff       	call   80102eae <lapicinit>
  seginit();       // set up segments
801038c4:	e8 83 41 00 00       	call   80107a4c <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038c9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038cf:	0f b6 00             	movzbl (%eax),%eax
801038d2:	0f b6 c0             	movzbl %al,%eax
801038d5:	83 ec 08             	sub    $0x8,%esp
801038d8:	50                   	push   %eax
801038d9:	68 d4 8a 10 80       	push   $0x80108ad4
801038de:	e8 e3 ca ff ff       	call   801003c6 <cprintf>
801038e3:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038e6:	e8 6d 06 00 00       	call   80103f58 <picinit>
  ioapicinit();    // another interrupt controller
801038eb:	e8 34 f1 ff ff       	call   80102a24 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038f0:	e8 24 d2 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
801038f5:	e8 ae 34 00 00       	call   80106da8 <uartinit>
  pinit();         // process table
801038fa:	e8 94 0b 00 00       	call   80104493 <pinit>
  tvinit();        // trap vectors
801038ff:	e8 6e 30 00 00       	call   80106972 <tvinit>
  binit();         // buffer cache
80103904:	e8 2b c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103909:	e8 67 d6 ff ff       	call   80100f75 <fileinit>
  ideinit();       // disk
8010390e:	e8 19 ed ff ff       	call   8010262c <ideinit>
  if(!ismp)
80103913:	a1 44 23 11 80       	mov    0x80112344,%eax
80103918:	85 c0                	test   %eax,%eax
8010391a:	75 05                	jne    80103921 <main+0x92>
    timerinit();   // uniprocessor timer
8010391c:	e8 ae 2f 00 00       	call   801068cf <timerinit>
  startothers();   // start other processors
80103921:	e8 7f 00 00 00       	call   801039a5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103926:	83 ec 08             	sub    $0x8,%esp
80103929:	68 00 00 00 8e       	push   $0x8e000000
8010392e:	68 00 00 40 80       	push   $0x80400000
80103933:	e8 30 f2 ff ff       	call   80102b68 <kinit2>
80103938:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010393b:	e8 87 0c 00 00       	call   801045c7 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103940:	e8 1a 00 00 00       	call   8010395f <mpmain>

80103945 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103945:	55                   	push   %ebp
80103946:	89 e5                	mov    %esp,%ebp
80103948:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010394b:	e8 6b 47 00 00       	call   801080bb <switchkvm>
  seginit();
80103950:	e8 f7 40 00 00       	call   80107a4c <seginit>
  lapicinit();
80103955:	e8 54 f5 ff ff       	call   80102eae <lapicinit>
  mpmain();
8010395a:	e8 00 00 00 00       	call   8010395f <mpmain>

8010395f <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010395f:	55                   	push   %ebp
80103960:	89 e5                	mov    %esp,%ebp
80103962:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103965:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396b:	0f b6 00             	movzbl (%eax),%eax
8010396e:	0f b6 c0             	movzbl %al,%eax
80103971:	83 ec 08             	sub    $0x8,%esp
80103974:	50                   	push   %eax
80103975:	68 eb 8a 10 80       	push   $0x80108aeb
8010397a:	e8 47 ca ff ff       	call   801003c6 <cprintf>
8010397f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103982:	e8 61 31 00 00       	call   80106ae8 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103987:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010398d:	05 a8 00 00 00       	add    $0xa8,%eax
80103992:	83 ec 08             	sub    $0x8,%esp
80103995:	6a 01                	push   $0x1
80103997:	50                   	push   %eax
80103998:	e8 d8 fe ff ff       	call   80103875 <xchg>
8010399d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039a0:	e8 d3 11 00 00       	call   80104b78 <scheduler>

801039a5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039a5:	55                   	push   %ebp
801039a6:	89 e5                	mov    %esp,%ebp
801039a8:	53                   	push   %ebx
801039a9:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039ac:	68 00 70 00 00       	push   $0x7000
801039b1:	e8 b2 fe ff ff       	call   80103868 <p2v>
801039b6:	83 c4 04             	add    $0x4,%esp
801039b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039bc:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039c1:	83 ec 04             	sub    $0x4,%esp
801039c4:	50                   	push   %eax
801039c5:	68 0c b5 10 80       	push   $0x8010b50c
801039ca:	ff 75 f0             	pushl  -0x10(%ebp)
801039cd:	e8 3f 1c 00 00       	call   80105611 <memmove>
801039d2:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039d5:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
801039dc:	e9 90 00 00 00       	jmp    80103a71 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801039e1:	e8 e6 f5 ff ff       	call   80102fcc <cpunum>
801039e6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039ec:	05 60 23 11 80       	add    $0x80112360,%eax
801039f1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f4:	74 73                	je     80103a69 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039f6:	e8 6b f2 ff ff       	call   80102c66 <kalloc>
801039fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a01:	83 e8 04             	sub    $0x4,%eax
80103a04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a07:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a0d:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a12:	83 e8 08             	sub    $0x8,%eax
80103a15:	c7 00 45 39 10 80    	movl   $0x80103945,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a1e:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 00 a0 10 80       	push   $0x8010a000
80103a29:	e8 2d fe ff ff       	call   8010385b <v2p>
80103a2e:	83 c4 10             	add    $0x10,%esp
80103a31:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a33:	83 ec 0c             	sub    $0xc,%esp
80103a36:	ff 75 f0             	pushl  -0x10(%ebp)
80103a39:	e8 1d fe ff ff       	call   8010385b <v2p>
80103a3e:	83 c4 10             	add    $0x10,%esp
80103a41:	89 c2                	mov    %eax,%edx
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	0f b6 00             	movzbl (%eax),%eax
80103a49:	0f b6 c0             	movzbl %al,%eax
80103a4c:	83 ec 08             	sub    $0x8,%esp
80103a4f:	52                   	push   %edx
80103a50:	50                   	push   %eax
80103a51:	e8 f0 f5 ff ff       	call   80103046 <lapicstartap>
80103a56:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a59:	90                   	nop
80103a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a63:	85 c0                	test   %eax,%eax
80103a65:	74 f3                	je     80103a5a <startothers+0xb5>
80103a67:	eb 01                	jmp    80103a6a <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103a69:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a6a:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a71:	a1 40 29 11 80       	mov    0x80112940,%eax
80103a76:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a7c:	05 60 23 11 80       	add    $0x80112360,%eax
80103a81:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a84:	0f 87 57 ff ff ff    	ja     801039e1 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a8a:	90                   	nop
80103a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a8e:	c9                   	leave  
80103a8f:	c3                   	ret    

80103a90 <p2v>:
80103a90:	55                   	push   %ebp
80103a91:	89 e5                	mov    %esp,%ebp
80103a93:	8b 45 08             	mov    0x8(%ebp),%eax
80103a96:	05 00 00 00 80       	add    $0x80000000,%eax
80103a9b:	5d                   	pop    %ebp
80103a9c:	c3                   	ret    

80103a9d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a9d:	55                   	push   %ebp
80103a9e:	89 e5                	mov    %esp,%ebp
80103aa0:	83 ec 14             	sub    $0x14,%esp
80103aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103aaa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103aae:	89 c2                	mov    %eax,%edx
80103ab0:	ec                   	in     (%dx),%al
80103ab1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ab4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ab8:	c9                   	leave  
80103ab9:	c3                   	ret    

80103aba <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103aba:	55                   	push   %ebp
80103abb:	89 e5                	mov    %esp,%ebp
80103abd:	83 ec 08             	sub    $0x8,%esp
80103ac0:	8b 55 08             	mov    0x8(%ebp),%edx
80103ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ac6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aca:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103acd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ad1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ad5:	ee                   	out    %al,(%dx)
}
80103ad6:	90                   	nop
80103ad7:	c9                   	leave  
80103ad8:	c3                   	ret    

80103ad9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103ad9:	55                   	push   %ebp
80103ada:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103adc:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103ae1:	89 c2                	mov    %eax,%edx
80103ae3:	b8 60 23 11 80       	mov    $0x80112360,%eax
80103ae8:	29 c2                	sub    %eax,%edx
80103aea:	89 d0                	mov    %edx,%eax
80103aec:	c1 f8 02             	sar    $0x2,%eax
80103aef:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103af5:	5d                   	pop    %ebp
80103af6:	c3                   	ret    

80103af7 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103af7:	55                   	push   %ebp
80103af8:	89 e5                	mov    %esp,%ebp
80103afa:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103afd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b04:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b0b:	eb 15                	jmp    80103b22 <sum+0x2b>
    sum += addr[i];
80103b0d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b10:	8b 45 08             	mov    0x8(%ebp),%eax
80103b13:	01 d0                	add    %edx,%eax
80103b15:	0f b6 00             	movzbl (%eax),%eax
80103b18:	0f b6 c0             	movzbl %al,%eax
80103b1b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b1e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b25:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b28:	7c e3                	jl     80103b0d <sum+0x16>
    sum += addr[i];
  return sum;
80103b2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b2d:	c9                   	leave  
80103b2e:	c3                   	ret    

80103b2f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b2f:	55                   	push   %ebp
80103b30:	89 e5                	mov    %esp,%ebp
80103b32:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b35:	ff 75 08             	pushl  0x8(%ebp)
80103b38:	e8 53 ff ff ff       	call   80103a90 <p2v>
80103b3d:	83 c4 04             	add    $0x4,%esp
80103b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b43:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b49:	01 d0                	add    %edx,%eax
80103b4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b54:	eb 36                	jmp    80103b8c <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b56:	83 ec 04             	sub    $0x4,%esp
80103b59:	6a 04                	push   $0x4
80103b5b:	68 fc 8a 10 80       	push   $0x80108afc
80103b60:	ff 75 f4             	pushl  -0xc(%ebp)
80103b63:	e8 51 1a 00 00       	call   801055b9 <memcmp>
80103b68:	83 c4 10             	add    $0x10,%esp
80103b6b:	85 c0                	test   %eax,%eax
80103b6d:	75 19                	jne    80103b88 <mpsearch1+0x59>
80103b6f:	83 ec 08             	sub    $0x8,%esp
80103b72:	6a 10                	push   $0x10
80103b74:	ff 75 f4             	pushl  -0xc(%ebp)
80103b77:	e8 7b ff ff ff       	call   80103af7 <sum>
80103b7c:	83 c4 10             	add    $0x10,%esp
80103b7f:	84 c0                	test   %al,%al
80103b81:	75 05                	jne    80103b88 <mpsearch1+0x59>
      return (struct mp*)p;
80103b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b86:	eb 11                	jmp    80103b99 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b88:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b92:	72 c2                	jb     80103b56 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b99:	c9                   	leave  
80103b9a:	c3                   	ret    

80103b9b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b9b:	55                   	push   %ebp
80103b9c:	89 e5                	mov    %esp,%ebp
80103b9e:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ba1:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bab:	83 c0 0f             	add    $0xf,%eax
80103bae:	0f b6 00             	movzbl (%eax),%eax
80103bb1:	0f b6 c0             	movzbl %al,%eax
80103bb4:	c1 e0 08             	shl    $0x8,%eax
80103bb7:	89 c2                	mov    %eax,%edx
80103bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbc:	83 c0 0e             	add    $0xe,%eax
80103bbf:	0f b6 00             	movzbl (%eax),%eax
80103bc2:	0f b6 c0             	movzbl %al,%eax
80103bc5:	09 d0                	or     %edx,%eax
80103bc7:	c1 e0 04             	shl    $0x4,%eax
80103bca:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bcd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bd1:	74 21                	je     80103bf4 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bd3:	83 ec 08             	sub    $0x8,%esp
80103bd6:	68 00 04 00 00       	push   $0x400
80103bdb:	ff 75 f0             	pushl  -0x10(%ebp)
80103bde:	e8 4c ff ff ff       	call   80103b2f <mpsearch1>
80103be3:	83 c4 10             	add    $0x10,%esp
80103be6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103be9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bed:	74 51                	je     80103c40 <mpsearch+0xa5>
      return mp;
80103bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bf2:	eb 61                	jmp    80103c55 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf7:	83 c0 14             	add    $0x14,%eax
80103bfa:	0f b6 00             	movzbl (%eax),%eax
80103bfd:	0f b6 c0             	movzbl %al,%eax
80103c00:	c1 e0 08             	shl    $0x8,%eax
80103c03:	89 c2                	mov    %eax,%edx
80103c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c08:	83 c0 13             	add    $0x13,%eax
80103c0b:	0f b6 00             	movzbl (%eax),%eax
80103c0e:	0f b6 c0             	movzbl %al,%eax
80103c11:	09 d0                	or     %edx,%eax
80103c13:	c1 e0 0a             	shl    $0xa,%eax
80103c16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1c:	2d 00 04 00 00       	sub    $0x400,%eax
80103c21:	83 ec 08             	sub    $0x8,%esp
80103c24:	68 00 04 00 00       	push   $0x400
80103c29:	50                   	push   %eax
80103c2a:	e8 00 ff ff ff       	call   80103b2f <mpsearch1>
80103c2f:	83 c4 10             	add    $0x10,%esp
80103c32:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c35:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c39:	74 05                	je     80103c40 <mpsearch+0xa5>
      return mp;
80103c3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c3e:	eb 15                	jmp    80103c55 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c40:	83 ec 08             	sub    $0x8,%esp
80103c43:	68 00 00 01 00       	push   $0x10000
80103c48:	68 00 00 0f 00       	push   $0xf0000
80103c4d:	e8 dd fe ff ff       	call   80103b2f <mpsearch1>
80103c52:	83 c4 10             	add    $0x10,%esp
}
80103c55:	c9                   	leave  
80103c56:	c3                   	ret    

80103c57 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c57:	55                   	push   %ebp
80103c58:	89 e5                	mov    %esp,%ebp
80103c5a:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c5d:	e8 39 ff ff ff       	call   80103b9b <mpsearch>
80103c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c69:	74 0a                	je     80103c75 <mpconfig+0x1e>
80103c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6e:	8b 40 04             	mov    0x4(%eax),%eax
80103c71:	85 c0                	test   %eax,%eax
80103c73:	75 0a                	jne    80103c7f <mpconfig+0x28>
    return 0;
80103c75:	b8 00 00 00 00       	mov    $0x0,%eax
80103c7a:	e9 81 00 00 00       	jmp    80103d00 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	8b 40 04             	mov    0x4(%eax),%eax
80103c85:	83 ec 0c             	sub    $0xc,%esp
80103c88:	50                   	push   %eax
80103c89:	e8 02 fe ff ff       	call   80103a90 <p2v>
80103c8e:	83 c4 10             	add    $0x10,%esp
80103c91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c94:	83 ec 04             	sub    $0x4,%esp
80103c97:	6a 04                	push   $0x4
80103c99:	68 01 8b 10 80       	push   $0x80108b01
80103c9e:	ff 75 f0             	pushl  -0x10(%ebp)
80103ca1:	e8 13 19 00 00       	call   801055b9 <memcmp>
80103ca6:	83 c4 10             	add    $0x10,%esp
80103ca9:	85 c0                	test   %eax,%eax
80103cab:	74 07                	je     80103cb4 <mpconfig+0x5d>
    return 0;
80103cad:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb2:	eb 4c                	jmp    80103d00 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb7:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cbb:	3c 01                	cmp    $0x1,%al
80103cbd:	74 12                	je     80103cd1 <mpconfig+0x7a>
80103cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc2:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cc6:	3c 04                	cmp    $0x4,%al
80103cc8:	74 07                	je     80103cd1 <mpconfig+0x7a>
    return 0;
80103cca:	b8 00 00 00 00       	mov    $0x0,%eax
80103ccf:	eb 2f                	jmp    80103d00 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cd8:	0f b7 c0             	movzwl %ax,%eax
80103cdb:	83 ec 08             	sub    $0x8,%esp
80103cde:	50                   	push   %eax
80103cdf:	ff 75 f0             	pushl  -0x10(%ebp)
80103ce2:	e8 10 fe ff ff       	call   80103af7 <sum>
80103ce7:	83 c4 10             	add    $0x10,%esp
80103cea:	84 c0                	test   %al,%al
80103cec:	74 07                	je     80103cf5 <mpconfig+0x9e>
    return 0;
80103cee:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf3:	eb 0b                	jmp    80103d00 <mpconfig+0xa9>
  *pmp = mp;
80103cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cfb:	89 10                	mov    %edx,(%eax)
  return conf;
80103cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d00:	c9                   	leave  
80103d01:	c3                   	ret    

80103d02 <mpinit>:

void
mpinit(void)
{
80103d02:	55                   	push   %ebp
80103d03:	89 e5                	mov    %esp,%ebp
80103d05:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d08:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103d0f:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d12:	83 ec 0c             	sub    $0xc,%esp
80103d15:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d18:	50                   	push   %eax
80103d19:	e8 39 ff ff ff       	call   80103c57 <mpconfig>
80103d1e:	83 c4 10             	add    $0x10,%esp
80103d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d28:	0f 84 96 01 00 00    	je     80103ec4 <mpinit+0x1c2>
    return;
  ismp = 1;
80103d2e:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103d35:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3b:	8b 40 24             	mov    0x24(%eax),%eax
80103d3e:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d46:	83 c0 2c             	add    $0x2c,%eax
80103d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d53:	0f b7 d0             	movzwl %ax,%edx
80103d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d59:	01 d0                	add    %edx,%eax
80103d5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d5e:	e9 f2 00 00 00       	jmp    80103e55 <mpinit+0x153>
    switch(*p){
80103d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d66:	0f b6 00             	movzbl (%eax),%eax
80103d69:	0f b6 c0             	movzbl %al,%eax
80103d6c:	83 f8 04             	cmp    $0x4,%eax
80103d6f:	0f 87 bc 00 00 00    	ja     80103e31 <mpinit+0x12f>
80103d75:	8b 04 85 44 8b 10 80 	mov    -0x7fef74bc(,%eax,4),%eax
80103d7c:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d81:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d87:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d8b:	0f b6 d0             	movzbl %al,%edx
80103d8e:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d93:	39 c2                	cmp    %eax,%edx
80103d95:	74 2b                	je     80103dc2 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d9a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d9e:	0f b6 d0             	movzbl %al,%edx
80103da1:	a1 40 29 11 80       	mov    0x80112940,%eax
80103da6:	83 ec 04             	sub    $0x4,%esp
80103da9:	52                   	push   %edx
80103daa:	50                   	push   %eax
80103dab:	68 06 8b 10 80       	push   $0x80108b06
80103db0:	e8 11 c6 ff ff       	call   801003c6 <cprintf>
80103db5:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103db8:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103dbf:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103dc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103dc5:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103dc9:	0f b6 c0             	movzbl %al,%eax
80103dcc:	83 e0 02             	and    $0x2,%eax
80103dcf:	85 c0                	test   %eax,%eax
80103dd1:	74 15                	je     80103de8 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103dd3:	a1 40 29 11 80       	mov    0x80112940,%eax
80103dd8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dde:	05 60 23 11 80       	add    $0x80112360,%eax
80103de3:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103de8:	a1 40 29 11 80       	mov    0x80112940,%eax
80103ded:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103df3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103df9:	05 60 23 11 80       	add    $0x80112360,%eax
80103dfe:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e00:	a1 40 29 11 80       	mov    0x80112940,%eax
80103e05:	83 c0 01             	add    $0x1,%eax
80103e08:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103e0d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e11:	eb 42                	jmp    80103e55 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e1c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e20:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103e25:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e29:	eb 2a                	jmp    80103e55 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e2b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e2f:	eb 24                	jmp    80103e55 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e34:	0f b6 00             	movzbl (%eax),%eax
80103e37:	0f b6 c0             	movzbl %al,%eax
80103e3a:	83 ec 08             	sub    $0x8,%esp
80103e3d:	50                   	push   %eax
80103e3e:	68 24 8b 10 80       	push   $0x80108b24
80103e43:	e8 7e c5 ff ff       	call   801003c6 <cprintf>
80103e48:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e4b:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103e52:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e58:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e5b:	0f 82 02 ff ff ff    	jb     80103d63 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103e61:	a1 44 23 11 80       	mov    0x80112344,%eax
80103e66:	85 c0                	test   %eax,%eax
80103e68:	75 1d                	jne    80103e87 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e6a:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103e71:	00 00 00 
    lapic = 0;
80103e74:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103e7b:	00 00 00 
    ioapicid = 0;
80103e7e:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103e85:	eb 3e                	jmp    80103ec5 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e8e:	84 c0                	test   %al,%al
80103e90:	74 33                	je     80103ec5 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e92:	83 ec 08             	sub    $0x8,%esp
80103e95:	6a 70                	push   $0x70
80103e97:	6a 22                	push   $0x22
80103e99:	e8 1c fc ff ff       	call   80103aba <outb>
80103e9e:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ea1:	83 ec 0c             	sub    $0xc,%esp
80103ea4:	6a 23                	push   $0x23
80103ea6:	e8 f2 fb ff ff       	call   80103a9d <inb>
80103eab:	83 c4 10             	add    $0x10,%esp
80103eae:	83 c8 01             	or     $0x1,%eax
80103eb1:	0f b6 c0             	movzbl %al,%eax
80103eb4:	83 ec 08             	sub    $0x8,%esp
80103eb7:	50                   	push   %eax
80103eb8:	6a 23                	push   $0x23
80103eba:	e8 fb fb ff ff       	call   80103aba <outb>
80103ebf:	83 c4 10             	add    $0x10,%esp
80103ec2:	eb 01                	jmp    80103ec5 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103ec4:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103ec5:	c9                   	leave  
80103ec6:	c3                   	ret    

80103ec7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ec7:	55                   	push   %ebp
80103ec8:	89 e5                	mov    %esp,%ebp
80103eca:	83 ec 08             	sub    $0x8,%esp
80103ecd:	8b 55 08             	mov    0x8(%ebp),%edx
80103ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ed7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103eda:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ede:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ee2:	ee                   	out    %al,(%dx)
}
80103ee3:	90                   	nop
80103ee4:	c9                   	leave  
80103ee5:	c3                   	ret    

80103ee6 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ee6:	55                   	push   %ebp
80103ee7:	89 e5                	mov    %esp,%ebp
80103ee9:	83 ec 04             	sub    $0x4,%esp
80103eec:	8b 45 08             	mov    0x8(%ebp),%eax
80103eef:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ef3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ef7:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103efd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f01:	0f b6 c0             	movzbl %al,%eax
80103f04:	50                   	push   %eax
80103f05:	6a 21                	push   $0x21
80103f07:	e8 bb ff ff ff       	call   80103ec7 <outb>
80103f0c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f0f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f13:	66 c1 e8 08          	shr    $0x8,%ax
80103f17:	0f b6 c0             	movzbl %al,%eax
80103f1a:	50                   	push   %eax
80103f1b:	68 a1 00 00 00       	push   $0xa1
80103f20:	e8 a2 ff ff ff       	call   80103ec7 <outb>
80103f25:	83 c4 08             	add    $0x8,%esp
}
80103f28:	90                   	nop
80103f29:	c9                   	leave  
80103f2a:	c3                   	ret    

80103f2b <picenable>:

void
picenable(int irq)
{
80103f2b:	55                   	push   %ebp
80103f2c:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f31:	ba 01 00 00 00       	mov    $0x1,%edx
80103f36:	89 c1                	mov    %eax,%ecx
80103f38:	d3 e2                	shl    %cl,%edx
80103f3a:	89 d0                	mov    %edx,%eax
80103f3c:	f7 d0                	not    %eax
80103f3e:	89 c2                	mov    %eax,%edx
80103f40:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f47:	21 d0                	and    %edx,%eax
80103f49:	0f b7 c0             	movzwl %ax,%eax
80103f4c:	50                   	push   %eax
80103f4d:	e8 94 ff ff ff       	call   80103ee6 <picsetmask>
80103f52:	83 c4 04             	add    $0x4,%esp
}
80103f55:	90                   	nop
80103f56:	c9                   	leave  
80103f57:	c3                   	ret    

80103f58 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f58:	55                   	push   %ebp
80103f59:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f5b:	68 ff 00 00 00       	push   $0xff
80103f60:	6a 21                	push   $0x21
80103f62:	e8 60 ff ff ff       	call   80103ec7 <outb>
80103f67:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f6a:	68 ff 00 00 00       	push   $0xff
80103f6f:	68 a1 00 00 00       	push   $0xa1
80103f74:	e8 4e ff ff ff       	call   80103ec7 <outb>
80103f79:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103f7c:	6a 11                	push   $0x11
80103f7e:	6a 20                	push   $0x20
80103f80:	e8 42 ff ff ff       	call   80103ec7 <outb>
80103f85:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f88:	6a 20                	push   $0x20
80103f8a:	6a 21                	push   $0x21
80103f8c:	e8 36 ff ff ff       	call   80103ec7 <outb>
80103f91:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f94:	6a 04                	push   $0x4
80103f96:	6a 21                	push   $0x21
80103f98:	e8 2a ff ff ff       	call   80103ec7 <outb>
80103f9d:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fa0:	6a 03                	push   $0x3
80103fa2:	6a 21                	push   $0x21
80103fa4:	e8 1e ff ff ff       	call   80103ec7 <outb>
80103fa9:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fac:	6a 11                	push   $0x11
80103fae:	68 a0 00 00 00       	push   $0xa0
80103fb3:	e8 0f ff ff ff       	call   80103ec7 <outb>
80103fb8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103fbb:	6a 28                	push   $0x28
80103fbd:	68 a1 00 00 00       	push   $0xa1
80103fc2:	e8 00 ff ff ff       	call   80103ec7 <outb>
80103fc7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103fca:	6a 02                	push   $0x2
80103fcc:	68 a1 00 00 00       	push   $0xa1
80103fd1:	e8 f1 fe ff ff       	call   80103ec7 <outb>
80103fd6:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103fd9:	6a 03                	push   $0x3
80103fdb:	68 a1 00 00 00       	push   $0xa1
80103fe0:	e8 e2 fe ff ff       	call   80103ec7 <outb>
80103fe5:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103fe8:	6a 68                	push   $0x68
80103fea:	6a 20                	push   $0x20
80103fec:	e8 d6 fe ff ff       	call   80103ec7 <outb>
80103ff1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ff4:	6a 0a                	push   $0xa
80103ff6:	6a 20                	push   $0x20
80103ff8:	e8 ca fe ff ff       	call   80103ec7 <outb>
80103ffd:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104000:	6a 68                	push   $0x68
80104002:	68 a0 00 00 00       	push   $0xa0
80104007:	e8 bb fe ff ff       	call   80103ec7 <outb>
8010400c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010400f:	6a 0a                	push   $0xa
80104011:	68 a0 00 00 00       	push   $0xa0
80104016:	e8 ac fe ff ff       	call   80103ec7 <outb>
8010401b:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010401e:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104025:	66 83 f8 ff          	cmp    $0xffff,%ax
80104029:	74 13                	je     8010403e <picinit+0xe6>
    picsetmask(irqmask);
8010402b:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104032:	0f b7 c0             	movzwl %ax,%eax
80104035:	50                   	push   %eax
80104036:	e8 ab fe ff ff       	call   80103ee6 <picsetmask>
8010403b:	83 c4 04             	add    $0x4,%esp
}
8010403e:	90                   	nop
8010403f:	c9                   	leave  
80104040:	c3                   	ret    

80104041 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104041:	55                   	push   %ebp
80104042:	89 e5                	mov    %esp,%ebp
80104044:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104047:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010404e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104051:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405a:	8b 10                	mov    (%eax),%edx
8010405c:	8b 45 08             	mov    0x8(%ebp),%eax
8010405f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104061:	e8 2d cf ff ff       	call   80100f93 <filealloc>
80104066:	89 c2                	mov    %eax,%edx
80104068:	8b 45 08             	mov    0x8(%ebp),%eax
8010406b:	89 10                	mov    %edx,(%eax)
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 00                	mov    (%eax),%eax
80104072:	85 c0                	test   %eax,%eax
80104074:	0f 84 cb 00 00 00    	je     80104145 <pipealloc+0x104>
8010407a:	e8 14 cf ff ff       	call   80100f93 <filealloc>
8010407f:	89 c2                	mov    %eax,%edx
80104081:	8b 45 0c             	mov    0xc(%ebp),%eax
80104084:	89 10                	mov    %edx,(%eax)
80104086:	8b 45 0c             	mov    0xc(%ebp),%eax
80104089:	8b 00                	mov    (%eax),%eax
8010408b:	85 c0                	test   %eax,%eax
8010408d:	0f 84 b2 00 00 00    	je     80104145 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104093:	e8 ce eb ff ff       	call   80102c66 <kalloc>
80104098:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010409b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010409f:	0f 84 9f 00 00 00    	je     80104144 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801040a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040af:	00 00 00 
  p->writeopen = 1;
801040b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040bc:	00 00 00 
  p->nwrite = 0;
801040bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040c9:	00 00 00 
  p->nread = 0;
801040cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cf:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040d6:	00 00 00 
  initlock(&p->lock, "pipe");
801040d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dc:	83 ec 08             	sub    $0x8,%esp
801040df:	68 58 8b 10 80       	push   $0x80108b58
801040e4:	50                   	push   %eax
801040e5:	e8 e3 11 00 00       	call   801052cd <initlock>
801040ea:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040ed:	8b 45 08             	mov    0x8(%ebp),%eax
801040f0:	8b 00                	mov    (%eax),%eax
801040f2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040f8:	8b 45 08             	mov    0x8(%ebp),%eax
801040fb:	8b 00                	mov    (%eax),%eax
801040fd:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104101:	8b 45 08             	mov    0x8(%ebp),%eax
80104104:	8b 00                	mov    (%eax),%eax
80104106:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010410a:	8b 45 08             	mov    0x8(%ebp),%eax
8010410d:	8b 00                	mov    (%eax),%eax
8010410f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104112:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104115:	8b 45 0c             	mov    0xc(%ebp),%eax
80104118:	8b 00                	mov    (%eax),%eax
8010411a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104120:	8b 45 0c             	mov    0xc(%ebp),%eax
80104123:	8b 00                	mov    (%eax),%eax
80104125:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104129:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412c:	8b 00                	mov    (%eax),%eax
8010412e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104132:	8b 45 0c             	mov    0xc(%ebp),%eax
80104135:	8b 00                	mov    (%eax),%eax
80104137:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413a:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010413d:	b8 00 00 00 00       	mov    $0x0,%eax
80104142:	eb 4e                	jmp    80104192 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104144:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104149:	74 0e                	je     80104159 <pipealloc+0x118>
    kfree((char*)p);
8010414b:	83 ec 0c             	sub    $0xc,%esp
8010414e:	ff 75 f4             	pushl  -0xc(%ebp)
80104151:	e8 73 ea ff ff       	call   80102bc9 <kfree>
80104156:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104159:	8b 45 08             	mov    0x8(%ebp),%eax
8010415c:	8b 00                	mov    (%eax),%eax
8010415e:	85 c0                	test   %eax,%eax
80104160:	74 11                	je     80104173 <pipealloc+0x132>
    fileclose(*f0);
80104162:	8b 45 08             	mov    0x8(%ebp),%eax
80104165:	8b 00                	mov    (%eax),%eax
80104167:	83 ec 0c             	sub    $0xc,%esp
8010416a:	50                   	push   %eax
8010416b:	e8 e1 ce ff ff       	call   80101051 <fileclose>
80104170:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104173:	8b 45 0c             	mov    0xc(%ebp),%eax
80104176:	8b 00                	mov    (%eax),%eax
80104178:	85 c0                	test   %eax,%eax
8010417a:	74 11                	je     8010418d <pipealloc+0x14c>
    fileclose(*f1);
8010417c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010417f:	8b 00                	mov    (%eax),%eax
80104181:	83 ec 0c             	sub    $0xc,%esp
80104184:	50                   	push   %eax
80104185:	e8 c7 ce ff ff       	call   80101051 <fileclose>
8010418a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010418d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104192:	c9                   	leave  
80104193:	c3                   	ret    

80104194 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104194:	55                   	push   %ebp
80104195:	89 e5                	mov    %esp,%ebp
80104197:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	83 ec 0c             	sub    $0xc,%esp
801041a0:	50                   	push   %eax
801041a1:	e8 49 11 00 00       	call   801052ef <acquire>
801041a6:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041ad:	74 23                	je     801041d2 <pipeclose+0x3e>
    p->writeopen = 0;
801041af:	8b 45 08             	mov    0x8(%ebp),%eax
801041b2:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041b9:	00 00 00 
    wakeup(&p->nread);
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	05 34 02 00 00       	add    $0x234,%eax
801041c4:	83 ec 0c             	sub    $0xc,%esp
801041c7:	50                   	push   %eax
801041c8:	e8 0e 0f 00 00       	call   801050db <wakeup>
801041cd:	83 c4 10             	add    $0x10,%esp
801041d0:	eb 21                	jmp    801041f3 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801041d2:	8b 45 08             	mov    0x8(%ebp),%eax
801041d5:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041dc:	00 00 00 
    wakeup(&p->nwrite);
801041df:	8b 45 08             	mov    0x8(%ebp),%eax
801041e2:	05 38 02 00 00       	add    $0x238,%eax
801041e7:	83 ec 0c             	sub    $0xc,%esp
801041ea:	50                   	push   %eax
801041eb:	e8 eb 0e 00 00       	call   801050db <wakeup>
801041f0:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041f3:	8b 45 08             	mov    0x8(%ebp),%eax
801041f6:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041fc:	85 c0                	test   %eax,%eax
801041fe:	75 2c                	jne    8010422c <pipeclose+0x98>
80104200:	8b 45 08             	mov    0x8(%ebp),%eax
80104203:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104209:	85 c0                	test   %eax,%eax
8010420b:	75 1f                	jne    8010422c <pipeclose+0x98>
    release(&p->lock);
8010420d:	8b 45 08             	mov    0x8(%ebp),%eax
80104210:	83 ec 0c             	sub    $0xc,%esp
80104213:	50                   	push   %eax
80104214:	e8 3d 11 00 00       	call   80105356 <release>
80104219:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010421c:	83 ec 0c             	sub    $0xc,%esp
8010421f:	ff 75 08             	pushl  0x8(%ebp)
80104222:	e8 a2 e9 ff ff       	call   80102bc9 <kfree>
80104227:	83 c4 10             	add    $0x10,%esp
8010422a:	eb 0f                	jmp    8010423b <pipeclose+0xa7>
  } else
    release(&p->lock);
8010422c:	8b 45 08             	mov    0x8(%ebp),%eax
8010422f:	83 ec 0c             	sub    $0xc,%esp
80104232:	50                   	push   %eax
80104233:	e8 1e 11 00 00       	call   80105356 <release>
80104238:	83 c4 10             	add    $0x10,%esp
}
8010423b:	90                   	nop
8010423c:	c9                   	leave  
8010423d:	c3                   	ret    

8010423e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010423e:	55                   	push   %ebp
8010423f:	89 e5                	mov    %esp,%ebp
80104241:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104244:	8b 45 08             	mov    0x8(%ebp),%eax
80104247:	83 ec 0c             	sub    $0xc,%esp
8010424a:	50                   	push   %eax
8010424b:	e8 9f 10 00 00       	call   801052ef <acquire>
80104250:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104253:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010425a:	e9 ad 00 00 00       	jmp    8010430c <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010425f:	8b 45 08             	mov    0x8(%ebp),%eax
80104262:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104268:	85 c0                	test   %eax,%eax
8010426a:	74 0d                	je     80104279 <pipewrite+0x3b>
8010426c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104272:	8b 40 24             	mov    0x24(%eax),%eax
80104275:	85 c0                	test   %eax,%eax
80104277:	74 19                	je     80104292 <pipewrite+0x54>
        release(&p->lock);
80104279:	8b 45 08             	mov    0x8(%ebp),%eax
8010427c:	83 ec 0c             	sub    $0xc,%esp
8010427f:	50                   	push   %eax
80104280:	e8 d1 10 00 00       	call   80105356 <release>
80104285:	83 c4 10             	add    $0x10,%esp
        return -1;
80104288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428d:	e9 a8 00 00 00       	jmp    8010433a <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104292:	8b 45 08             	mov    0x8(%ebp),%eax
80104295:	05 34 02 00 00       	add    $0x234,%eax
8010429a:	83 ec 0c             	sub    $0xc,%esp
8010429d:	50                   	push   %eax
8010429e:	e8 38 0e 00 00       	call   801050db <wakeup>
801042a3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042a6:	8b 45 08             	mov    0x8(%ebp),%eax
801042a9:	8b 55 08             	mov    0x8(%ebp),%edx
801042ac:	81 c2 38 02 00 00    	add    $0x238,%edx
801042b2:	83 ec 08             	sub    $0x8,%esp
801042b5:	50                   	push   %eax
801042b6:	52                   	push   %edx
801042b7:	e8 31 0d 00 00       	call   80104fed <sleep>
801042bc:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042c8:	8b 45 08             	mov    0x8(%ebp),%eax
801042cb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042d1:	05 00 02 00 00       	add    $0x200,%eax
801042d6:	39 c2                	cmp    %eax,%edx
801042d8:	74 85                	je     8010425f <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042da:	8b 45 08             	mov    0x8(%ebp),%eax
801042dd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e3:	8d 48 01             	lea    0x1(%eax),%ecx
801042e6:	8b 55 08             	mov    0x8(%ebp),%edx
801042e9:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042ef:	25 ff 01 00 00       	and    $0x1ff,%eax
801042f4:	89 c1                	mov    %eax,%ecx
801042f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801042fc:	01 d0                	add    %edx,%eax
801042fe:	0f b6 10             	movzbl (%eax),%edx
80104301:	8b 45 08             	mov    0x8(%ebp),%eax
80104304:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104308:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	3b 45 10             	cmp    0x10(%ebp),%eax
80104312:	7c ab                	jl     801042bf <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104314:	8b 45 08             	mov    0x8(%ebp),%eax
80104317:	05 34 02 00 00       	add    $0x234,%eax
8010431c:	83 ec 0c             	sub    $0xc,%esp
8010431f:	50                   	push   %eax
80104320:	e8 b6 0d 00 00       	call   801050db <wakeup>
80104325:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104328:	8b 45 08             	mov    0x8(%ebp),%eax
8010432b:	83 ec 0c             	sub    $0xc,%esp
8010432e:	50                   	push   %eax
8010432f:	e8 22 10 00 00       	call   80105356 <release>
80104334:	83 c4 10             	add    $0x10,%esp
  return n;
80104337:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010433a:	c9                   	leave  
8010433b:	c3                   	ret    

8010433c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010433c:	55                   	push   %ebp
8010433d:	89 e5                	mov    %esp,%ebp
8010433f:	53                   	push   %ebx
80104340:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	83 ec 0c             	sub    $0xc,%esp
80104349:	50                   	push   %eax
8010434a:	e8 a0 0f 00 00       	call   801052ef <acquire>
8010434f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104352:	eb 3f                	jmp    80104393 <piperead+0x57>
    if(proc->killed){
80104354:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010435a:	8b 40 24             	mov    0x24(%eax),%eax
8010435d:	85 c0                	test   %eax,%eax
8010435f:	74 19                	je     8010437a <piperead+0x3e>
      release(&p->lock);
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	83 ec 0c             	sub    $0xc,%esp
80104367:	50                   	push   %eax
80104368:	e8 e9 0f 00 00       	call   80105356 <release>
8010436d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104375:	e9 bf 00 00 00       	jmp    80104439 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010437a:	8b 45 08             	mov    0x8(%ebp),%eax
8010437d:	8b 55 08             	mov    0x8(%ebp),%edx
80104380:	81 c2 34 02 00 00    	add    $0x234,%edx
80104386:	83 ec 08             	sub    $0x8,%esp
80104389:	50                   	push   %eax
8010438a:	52                   	push   %edx
8010438b:	e8 5d 0c 00 00       	call   80104fed <sleep>
80104390:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104393:	8b 45 08             	mov    0x8(%ebp),%eax
80104396:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010439c:	8b 45 08             	mov    0x8(%ebp),%eax
8010439f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043a5:	39 c2                	cmp    %eax,%edx
801043a7:	75 0d                	jne    801043b6 <piperead+0x7a>
801043a9:	8b 45 08             	mov    0x8(%ebp),%eax
801043ac:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043b2:	85 c0                	test   %eax,%eax
801043b4:	75 9e                	jne    80104354 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043bd:	eb 49                	jmp    80104408 <piperead+0xcc>
    if(p->nread == p->nwrite)
801043bf:	8b 45 08             	mov    0x8(%ebp),%eax
801043c2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043c8:	8b 45 08             	mov    0x8(%ebp),%eax
801043cb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d1:	39 c2                	cmp    %eax,%edx
801043d3:	74 3d                	je     80104412 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801043db:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801043de:	8b 45 08             	mov    0x8(%ebp),%eax
801043e1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043e7:	8d 48 01             	lea    0x1(%eax),%ecx
801043ea:	8b 55 08             	mov    0x8(%ebp),%edx
801043ed:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801043f8:	89 c2                	mov    %eax,%edx
801043fa:	8b 45 08             	mov    0x8(%ebp),%eax
801043fd:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104402:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104404:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010440e:	7c af                	jl     801043bf <piperead+0x83>
80104410:	eb 01                	jmp    80104413 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104412:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	05 38 02 00 00       	add    $0x238,%eax
8010441b:	83 ec 0c             	sub    $0xc,%esp
8010441e:	50                   	push   %eax
8010441f:	e8 b7 0c 00 00       	call   801050db <wakeup>
80104424:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104427:	8b 45 08             	mov    0x8(%ebp),%eax
8010442a:	83 ec 0c             	sub    $0xc,%esp
8010442d:	50                   	push   %eax
8010442e:	e8 23 0f 00 00       	call   80105356 <release>
80104433:	83 c4 10             	add    $0x10,%esp
  return i;
80104436:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010443c:	c9                   	leave  
8010443d:	c3                   	ret    

8010443e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010443e:	55                   	push   %ebp
8010443f:	89 e5                	mov    %esp,%ebp
80104441:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104444:	9c                   	pushf  
80104445:	58                   	pop    %eax
80104446:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104449:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010444c:	c9                   	leave  
8010444d:	c3                   	ret    

8010444e <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010444e:	55                   	push   %ebp
8010444f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104451:	fb                   	sti    
}
80104452:	90                   	nop
80104453:	5d                   	pop    %ebp
80104454:	c3                   	ret    

80104455 <printQueue>:
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
//acceptting struct proc point p and the queue value - Ben Richards
void printQueue(struct proc *p, char* queue){ // Print the process name, ID, and what queue it ran in
80104455:	55                   	push   %ebp
80104456:	89 e5                	mov    %esp,%ebp
80104458:	83 ec 18             	sub    $0x18,%esp
  char *text1, *text2; 
  text1 = "Process";
8010445b:	c7 45 f4 5d 8b 10 80 	movl   $0x80108b5d,-0xc(%ebp)
  text2 = "has consumed 10 ms in";
80104462:	c7 45 f0 65 8b 10 80 	movl   $0x80108b65,-0x10(%ebp)

  cprintf( "%s %s %d %s %s\n", text1, p->name, p->pid, text2, queue );
80104469:	8b 45 08             	mov    0x8(%ebp),%eax
8010446c:	8b 40 10             	mov    0x10(%eax),%eax
8010446f:	8b 55 08             	mov    0x8(%ebp),%edx
80104472:	83 c2 6c             	add    $0x6c,%edx
80104475:	83 ec 08             	sub    $0x8,%esp
80104478:	ff 75 0c             	pushl  0xc(%ebp)
8010447b:	ff 75 f0             	pushl  -0x10(%ebp)
8010447e:	50                   	push   %eax
8010447f:	52                   	push   %edx
80104480:	ff 75 f4             	pushl  -0xc(%ebp)
80104483:	68 7b 8b 10 80       	push   $0x80108b7b
80104488:	e8 39 bf ff ff       	call   801003c6 <cprintf>
8010448d:	83 c4 20             	add    $0x20,%esp
  //void functions don't return anything. 
  //return;
}
80104490:	90                   	nop
80104491:	c9                   	leave  
80104492:	c3                   	ret    

80104493 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104493:	55                   	push   %ebp
80104494:	89 e5                	mov    %esp,%ebp
80104496:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104499:	83 ec 08             	sub    $0x8,%esp
8010449c:	68 8b 8b 10 80       	push   $0x80108b8b
801044a1:	68 60 29 11 80       	push   $0x80112960
801044a6:	e8 22 0e 00 00       	call   801052cd <initlock>
801044ab:	83 c4 10             	add    $0x10,%esp
}
801044ae:	90                   	nop
801044af:	c9                   	leave  
801044b0:	c3                   	ret    

801044b1 <allocproc>:
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*

allocproc(void)
{
801044b1:	55                   	push   %ebp
801044b2:	89 e5                	mov    %esp,%ebp
801044b4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044b7:	83 ec 0c             	sub    $0xc,%esp
801044ba:	68 60 29 11 80       	push   $0x80112960
801044bf:	e8 2b 0e 00 00       	call   801052ef <acquire>
801044c4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044c7:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801044ce:	eb 11                	jmp    801044e1 <allocproc+0x30>
    if(p->state == UNUSED)
801044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d3:	8b 40 0c             	mov    0xc(%eax),%eax
801044d6:	85 c0                	test   %eax,%eax
801044d8:	74 2a                	je     80104504 <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044da:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801044e1:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
801044e8:	72 e6                	jb     801044d0 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801044ea:	83 ec 0c             	sub    $0xc,%esp
801044ed:	68 60 29 11 80       	push   $0x80112960
801044f2:	e8 5f 0e 00 00       	call   80105356 <release>
801044f7:	83 c4 10             	add    $0x10,%esp
  return 0;
801044fa:	b8 00 00 00 00       	mov    $0x0,%eax
801044ff:	e9 c1 00 00 00       	jmp    801045c5 <allocproc+0x114>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104504:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104508:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010450f:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104514:	8d 50 01             	lea    0x1(%eax),%edx
80104517:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
8010451d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104520:	89 42 10             	mov    %eax,0x10(%edx)
  p->usageCounter = 0;
80104523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104526:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
8010452d:	00 00 00 
  release(&ptable.lock);
80104530:	83 ec 0c             	sub    $0xc,%esp
80104533:	68 60 29 11 80       	push   $0x80112960
80104538:	e8 19 0e 00 00       	call   80105356 <release>
8010453d:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104540:	e8 21 e7 ff ff       	call   80102c66 <kalloc>
80104545:	89 c2                	mov    %eax,%edx
80104547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454a:	89 50 08             	mov    %edx,0x8(%eax)
8010454d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104550:	8b 40 08             	mov    0x8(%eax),%eax
80104553:	85 c0                	test   %eax,%eax
80104555:	75 11                	jne    80104568 <allocproc+0xb7>
    p->state = UNUSED;
80104557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104561:	b8 00 00 00 00       	mov    $0x0,%eax
80104566:	eb 5d                	jmp    801045c5 <allocproc+0x114>
  }
  sp = p->kstack + KSTACKSIZE;
80104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456b:	8b 40 08             	mov    0x8(%eax),%eax
8010456e:	05 00 10 00 00       	add    $0x1000,%eax
80104573:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104576:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010457a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104580:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104583:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104587:	ba 2c 69 10 80       	mov    $0x8010692c,%edx
8010458c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010458f:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104591:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104598:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010459b:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010459e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a1:	8b 40 1c             	mov    0x1c(%eax),%eax
801045a4:	83 ec 04             	sub    $0x4,%esp
801045a7:	6a 14                	push   $0x14
801045a9:	6a 00                	push   $0x0
801045ab:	50                   	push   %eax
801045ac:	e8 a1 0f 00 00       	call   80105552 <memset>
801045b1:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b7:	8b 40 1c             	mov    0x1c(%eax),%eax
801045ba:	ba a7 4f 10 80       	mov    $0x80104fa7,%edx
801045bf:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045c5:	c9                   	leave  
801045c6:	c3                   	ret    

801045c7 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045c7:	55                   	push   %ebp
801045c8:	89 e5                	mov    %esp,%ebp
801045ca:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045cd:	e8 df fe ff ff       	call   801044b1 <allocproc>
801045d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d8:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
801045dd:	e8 0f 3a 00 00       	call   80107ff1 <setupkvm>
801045e2:	89 c2                	mov    %eax,%edx
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	89 50 04             	mov    %edx,0x4(%eax)
801045ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ed:	8b 40 04             	mov    0x4(%eax),%eax
801045f0:	85 c0                	test   %eax,%eax
801045f2:	75 0d                	jne    80104601 <userinit+0x3a>
    panic("userinit: out of memory?");
801045f4:	83 ec 0c             	sub    $0xc,%esp
801045f7:	68 92 8b 10 80       	push   $0x80108b92
801045fc:	e8 65 bf ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104601:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104609:	8b 40 04             	mov    0x4(%eax),%eax
8010460c:	83 ec 04             	sub    $0x4,%esp
8010460f:	52                   	push   %edx
80104610:	68 e0 b4 10 80       	push   $0x8010b4e0
80104615:	50                   	push   %eax
80104616:	e8 30 3c 00 00       	call   8010824b <inituvm>
8010461b:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010461e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104621:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462a:	8b 40 18             	mov    0x18(%eax),%eax
8010462d:	83 ec 04             	sub    $0x4,%esp
80104630:	6a 4c                	push   $0x4c
80104632:	6a 00                	push   $0x0
80104634:	50                   	push   %eax
80104635:	e8 18 0f 00 00       	call   80105552 <memset>
8010463a:	83 c4 10             	add    $0x10,%esp
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
801046aa:	83 ec 04             	sub    $0x4,%esp
801046ad:	6a 10                	push   $0x10
801046af:	68 ab 8b 10 80       	push   $0x80108bab
801046b4:	50                   	push   %eax
801046b5:	e8 9b 10 00 00       	call   80105755 <safestrcpy>
801046ba:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046bd:	83 ec 0c             	sub    $0xc,%esp
801046c0:	68 b4 8b 10 80       	push   $0x80108bb4
801046c5:	e8 5e de ff ff       	call   80102528 <namei>
801046ca:	83 c4 10             	add    $0x10,%esp
801046cd:	89 c2                	mov    %eax,%edx
801046cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d2:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801046d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046df:	90                   	nop
801046e0:	c9                   	leave  
801046e1:	c3                   	ret    

801046e2 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046e2:	55                   	push   %ebp
801046e3:	89 e5                	mov    %esp,%ebp
801046e5:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ee:	8b 00                	mov    (%eax),%eax
801046f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046f7:	7e 31                	jle    8010472a <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046f9:	8b 55 08             	mov    0x8(%ebp),%edx
801046fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ff:	01 c2                	add    %eax,%edx
80104701:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104707:	8b 40 04             	mov    0x4(%eax),%eax
8010470a:	83 ec 04             	sub    $0x4,%esp
8010470d:	52                   	push   %edx
8010470e:	ff 75 f4             	pushl  -0xc(%ebp)
80104711:	50                   	push   %eax
80104712:	e8 81 3c 00 00       	call   80108398 <allocuvm>
80104717:	83 c4 10             	add    $0x10,%esp
8010471a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010471d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104721:	75 3e                	jne    80104761 <growproc+0x7f>
      return -1;
80104723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104728:	eb 59                	jmp    80104783 <growproc+0xa1>
  } else if(n < 0){
8010472a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010472e:	79 31                	jns    80104761 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104730:	8b 55 08             	mov    0x8(%ebp),%edx
80104733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104736:	01 c2                	add    %eax,%edx
80104738:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473e:	8b 40 04             	mov    0x4(%eax),%eax
80104741:	83 ec 04             	sub    $0x4,%esp
80104744:	52                   	push   %edx
80104745:	ff 75 f4             	pushl  -0xc(%ebp)
80104748:	50                   	push   %eax
80104749:	e8 13 3d 00 00       	call   80108461 <deallocuvm>
8010474e:	83 c4 10             	add    $0x10,%esp
80104751:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104754:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104758:	75 07                	jne    80104761 <growproc+0x7f>
      return -1;
8010475a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010475f:	eb 22                	jmp    80104783 <growproc+0xa1>
  }
  proc->sz = sz;
80104761:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010476a:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010476c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104772:	83 ec 0c             	sub    $0xc,%esp
80104775:	50                   	push   %eax
80104776:	e8 5d 39 00 00       	call   801080d8 <switchuvm>
8010477b:	83 c4 10             	add    $0x10,%esp
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
8010478b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010478e:	e8 1e fd ff ff       	call   801044b1 <allocproc>
80104793:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010479a:	75 0a                	jne    801047a6 <fork+0x21>
    return -1;
8010479c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a1:	e9 68 01 00 00       	jmp    8010490e <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801047a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ac:	8b 10                	mov    (%eax),%edx
801047ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b4:	8b 40 04             	mov    0x4(%eax),%eax
801047b7:	83 ec 08             	sub    $0x8,%esp
801047ba:	52                   	push   %edx
801047bb:	50                   	push   %eax
801047bc:	e8 3e 3e 00 00       	call   801085ff <copyuvm>
801047c1:	83 c4 10             	add    $0x10,%esp
801047c4:	89 c2                	mov    %eax,%edx
801047c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c9:	89 50 04             	mov    %edx,0x4(%eax)
801047cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cf:	8b 40 04             	mov    0x4(%eax),%eax
801047d2:	85 c0                	test   %eax,%eax
801047d4:	75 30                	jne    80104806 <fork+0x81>
    kfree(np->kstack);
801047d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d9:	8b 40 08             	mov    0x8(%eax),%eax
801047dc:	83 ec 0c             	sub    $0xc,%esp
801047df:	50                   	push   %eax
801047e0:	e8 e4 e3 ff ff       	call   80102bc9 <kfree>
801047e5:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047eb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104801:	e9 08 01 00 00       	jmp    8010490e <fork+0x189>
  }
  np->sz = proc->sz;
80104806:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480c:	8b 10                	mov    (%eax),%edx
8010480e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104811:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104813:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010481a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481d:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104820:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104823:	8b 50 18             	mov    0x18(%eax),%edx
80104826:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010482c:	8b 40 18             	mov    0x18(%eax),%eax
8010482f:	89 c3                	mov    %eax,%ebx
80104831:	b8 13 00 00 00       	mov    $0x13,%eax
80104836:	89 d7                	mov    %edx,%edi
80104838:	89 de                	mov    %ebx,%esi
8010483a:	89 c1                	mov    %eax,%ecx
8010483c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010483e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104841:	8b 40 18             	mov    0x18(%eax),%eax
80104844:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010484b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104852:	eb 43                	jmp    80104897 <fork+0x112>
    if(proc->ofile[i])
80104854:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010485d:	83 c2 08             	add    $0x8,%edx
80104860:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104864:	85 c0                	test   %eax,%eax
80104866:	74 2b                	je     80104893 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104868:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104871:	83 c2 08             	add    $0x8,%edx
80104874:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104878:	83 ec 0c             	sub    $0xc,%esp
8010487b:	50                   	push   %eax
8010487c:	e8 7f c7 ff ff       	call   80101000 <filedup>
80104881:	83 c4 10             	add    $0x10,%esp
80104884:	89 c1                	mov    %eax,%ecx
80104886:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104889:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010488c:	83 c2 08             	add    $0x8,%edx
8010488f:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104893:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104897:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010489b:	7e b7                	jle    80104854 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010489d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a3:	8b 40 68             	mov    0x68(%eax),%eax
801048a6:	83 ec 0c             	sub    $0xc,%esp
801048a9:	50                   	push   %eax
801048aa:	e8 81 d0 ff ff       	call   80101930 <idup>
801048af:	83 c4 10             	add    $0x10,%esp
801048b2:	89 c2                	mov    %eax,%edx
801048b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b7:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c0:	8d 50 6c             	lea    0x6c(%eax),%edx
801048c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c6:	83 c0 6c             	add    $0x6c,%eax
801048c9:	83 ec 04             	sub    $0x4,%esp
801048cc:	6a 10                	push   $0x10
801048ce:	52                   	push   %edx
801048cf:	50                   	push   %eax
801048d0:	e8 80 0e 00 00       	call   80105755 <safestrcpy>
801048d5:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048db:	8b 40 10             	mov    0x10(%eax),%eax
801048de:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048e1:	83 ec 0c             	sub    $0xc,%esp
801048e4:	68 60 29 11 80       	push   $0x80112960
801048e9:	e8 01 0a 00 00       	call   801052ef <acquire>
801048ee:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048fb:	83 ec 0c             	sub    $0xc,%esp
801048fe:	68 60 29 11 80       	push   $0x80112960
80104903:	e8 4e 0a 00 00       	call   80105356 <release>
80104908:	83 c4 10             	add    $0x10,%esp
  
  return pid;
8010490b:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010490e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104911:	5b                   	pop    %ebx
80104912:	5e                   	pop    %esi
80104913:	5f                   	pop    %edi
80104914:	5d                   	pop    %ebp
80104915:	c3                   	ret    

80104916 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104916:	55                   	push   %ebp
80104917:	89 e5                	mov    %esp,%ebp
80104919:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010491c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104923:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104928:	39 c2                	cmp    %eax,%edx
8010492a:	75 0d                	jne    80104939 <exit+0x23>
    panic("init exiting");
8010492c:	83 ec 0c             	sub    $0xc,%esp
8010492f:	68 b6 8b 10 80       	push   $0x80108bb6
80104934:	e8 2d bc ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104939:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104940:	eb 48                	jmp    8010498a <exit+0x74>
    if(proc->ofile[fd]){
80104942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104948:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494b:	83 c2 08             	add    $0x8,%edx
8010494e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104952:	85 c0                	test   %eax,%eax
80104954:	74 30                	je     80104986 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104956:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010495c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010495f:	83 c2 08             	add    $0x8,%edx
80104962:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104966:	83 ec 0c             	sub    $0xc,%esp
80104969:	50                   	push   %eax
8010496a:	e8 e2 c6 ff ff       	call   80101051 <fileclose>
8010496f:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104972:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104978:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010497b:	83 c2 08             	add    $0x8,%edx
8010497e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104985:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104986:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010498a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010498e:	7e b2                	jle    80104942 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104990:	e8 b8 eb ff ff       	call   8010354d <begin_op>
  iput(proc->cwd);
80104995:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010499b:	8b 40 68             	mov    0x68(%eax),%eax
8010499e:	83 ec 0c             	sub    $0xc,%esp
801049a1:	50                   	push   %eax
801049a2:	e8 93 d1 ff ff       	call   80101b3a <iput>
801049a7:	83 c4 10             	add    $0x10,%esp
  end_op();
801049aa:	e8 2a ec ff ff       	call   801035d9 <end_op>
  proc->cwd = 0;
801049af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b5:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049bc:	83 ec 0c             	sub    $0xc,%esp
801049bf:	68 60 29 11 80       	push   $0x80112960
801049c4:	e8 26 09 00 00       	call   801052ef <acquire>
801049c9:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d2:	8b 40 14             	mov    0x14(%eax),%eax
801049d5:	83 ec 0c             	sub    $0xc,%esp
801049d8:	50                   	push   %eax
801049d9:	e8 bb 06 00 00       	call   80105099 <wakeup1>
801049de:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e1:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801049e8:	eb 3f                	jmp    80104a29 <exit+0x113>
    if(p->parent == proc){
801049ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ed:	8b 50 14             	mov    0x14(%eax),%edx
801049f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f6:	39 c2                	cmp    %eax,%edx
801049f8:	75 28                	jne    80104a22 <exit+0x10c>
      p->parent = initproc;
801049fa:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a03:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a09:	8b 40 0c             	mov    0xc(%eax),%eax
80104a0c:	83 f8 05             	cmp    $0x5,%eax
80104a0f:	75 11                	jne    80104a22 <exit+0x10c>
        wakeup1(initproc);
80104a11:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104a16:	83 ec 0c             	sub    $0xc,%esp
80104a19:	50                   	push   %eax
80104a1a:	e8 7a 06 00 00       	call   80105099 <wakeup1>
80104a1f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a22:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104a29:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
80104a30:	72 b8                	jb     801049ea <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a38:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a3f:	e8 6c 04 00 00       	call   80104eb0 <sched>
  panic("zombie exit");
80104a44:	83 ec 0c             	sub    $0xc,%esp
80104a47:	68 c3 8b 10 80       	push   $0x80108bc3
80104a4c:	e8 15 bb ff ff       	call   80100566 <panic>

80104a51 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a51:	55                   	push   %ebp
80104a52:	89 e5                	mov    %esp,%ebp
80104a54:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a57:	83 ec 0c             	sub    $0xc,%esp
80104a5a:	68 60 29 11 80       	push   $0x80112960
80104a5f:	e8 8b 08 00 00       	call   801052ef <acquire>
80104a64:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a67:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a6e:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a75:	e9 a9 00 00 00       	jmp    80104b23 <wait+0xd2>
      if(p->parent != proc)
80104a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7d:	8b 50 14             	mov    0x14(%eax),%edx
80104a80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a86:	39 c2                	cmp    %eax,%edx
80104a88:	0f 85 8d 00 00 00    	jne    80104b1b <wait+0xca>
        continue;
      havekids = 1;
80104a8e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	8b 40 0c             	mov    0xc(%eax),%eax
80104a9b:	83 f8 05             	cmp    $0x5,%eax
80104a9e:	75 7c                	jne    80104b1c <wait+0xcb>
        // Found one.
        pid = p->pid;
80104aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa3:	8b 40 10             	mov    0x10(%eax),%eax
80104aa6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aac:	8b 40 08             	mov    0x8(%eax),%eax
80104aaf:	83 ec 0c             	sub    $0xc,%esp
80104ab2:	50                   	push   %eax
80104ab3:	e8 11 e1 ff ff       	call   80102bc9 <kfree>
80104ab8:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac8:	8b 40 04             	mov    0x4(%eax),%eax
80104acb:	83 ec 0c             	sub    $0xc,%esp
80104ace:	50                   	push   %eax
80104acf:	e8 4a 3a 00 00       	call   8010851e <freevm>
80104ad4:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ada:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aee:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af8:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aff:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b06:	83 ec 0c             	sub    $0xc,%esp
80104b09:	68 60 29 11 80       	push   $0x80112960
80104b0e:	e8 43 08 00 00       	call   80105356 <release>
80104b13:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b19:	eb 5b                	jmp    80104b76 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b1b:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b1c:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104b23:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
80104b2a:	0f 82 4a ff ff ff    	jb     80104a7a <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b34:	74 0d                	je     80104b43 <wait+0xf2>
80104b36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b3c:	8b 40 24             	mov    0x24(%eax),%eax
80104b3f:	85 c0                	test   %eax,%eax
80104b41:	74 17                	je     80104b5a <wait+0x109>
      release(&ptable.lock);
80104b43:	83 ec 0c             	sub    $0xc,%esp
80104b46:	68 60 29 11 80       	push   $0x80112960
80104b4b:	e8 06 08 00 00       	call   80105356 <release>
80104b50:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b58:	eb 1c                	jmp    80104b76 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b60:	83 ec 08             	sub    $0x8,%esp
80104b63:	68 60 29 11 80       	push   $0x80112960
80104b68:	50                   	push   %eax
80104b69:	e8 7f 04 00 00       	call   80104fed <sleep>
80104b6e:	83 c4 10             	add    $0x10,%esp
  }
80104b71:	e9 f1 fe ff ff       	jmp    80104a67 <wait+0x16>
}
80104b76:	c9                   	leave  
80104b77:	c3                   	ret    

80104b78 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b78:	55                   	push   %ebp
80104b79:	89 e5                	mov    %esp,%ebp
80104b7b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p, *q;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b7e:	e8 cb f8 ff ff       	call   8010444e <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b83:	83 ec 0c             	sub    $0xc,%esp
80104b86:	68 60 29 11 80       	push   $0x80112960
80104b8b:	e8 5f 07 00 00       	call   801052ef <acquire>
80104b90:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ // Run FQ
80104b93:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104b9a:	e9 cf 00 00 00       	jmp    80104c6e <scheduler+0xf6>
      if(p->state != RUNNABLE)
80104b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba5:	83 f8 03             	cmp    $0x3,%eax
80104ba8:	0f 85 b2 00 00 00    	jne    80104c60 <scheduler+0xe8>
        continue;
      if(p->usageCounter != 0) continue;  // Skip process if it has already used the FQ
80104bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb1:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104bb7:	85 c0                	test   %eax,%eax
80104bb9:	0f 85 a4 00 00 00    	jne    80104c63 <scheduler+0xeb>
      strncpy(p->nameCopy, p->name, 16);  // Make a copy of the process's current name
80104bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc2:	8d 50 6c             	lea    0x6c(%eax),%edx
80104bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc8:	83 c0 7c             	add    $0x7c,%eax
80104bcb:	83 ec 04             	sub    $0x4,%esp
80104bce:	6a 10                	push   $0x10
80104bd0:	52                   	push   %edx
80104bd1:	50                   	push   %eax
80104bd2:	e8 26 0b 00 00       	call   801056fd <strncpy>
80104bd7:	83 c4 10             	add    $0x10,%esp
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdd:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104be3:	83 ec 0c             	sub    $0xc,%esp
80104be6:	ff 75 f4             	pushl  -0xc(%ebp)
80104be9:	e8 ea 34 00 00       	call   801080d8 <switchuvm>
80104bee:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
  
      if(p->pid == 5) continue;
80104bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfe:	8b 40 10             	mov    0x10(%eax),%eax
80104c01:	83 f8 05             	cmp    $0x5,%eax
80104c04:	74 60                	je     80104c66 <scheduler+0xee>

      swtch(&cpu->scheduler, proc->context);
80104c06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c0c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c0f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c16:	83 c2 04             	add    $0x4,%edx
80104c19:	83 ec 08             	sub    $0x8,%esp
80104c1c:	50                   	push   %eax
80104c1d:	52                   	push   %edx
80104c1e:	e8 a3 0b 00 00       	call   801057c6 <swtch>
80104c23:	83 c4 10             	add    $0x10,%esp
      printQueue(p, "FQ");
80104c26:	83 ec 08             	sub    $0x8,%esp
80104c29:	68 cf 8b 10 80       	push   $0x80108bcf
80104c2e:	ff 75 f4             	pushl  -0xc(%ebp)
80104c31:	e8 1f f8 ff ff       	call   80104455 <printQueue>
80104c36:	83 c4 10             	add    $0x10,%esp
      p->usageCounter++;  // Indicate that the process has used one 10ms interval
80104c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3c:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104c42:	8d 50 01             	lea    0x1(%eax),%edx
80104c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c48:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      switchkvm();
80104c4e:	e8 68 34 00 00       	call   801080bb <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c53:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c5a:	00 00 00 00 
80104c5e:	eb 07                	jmp    80104c67 <scheduler+0xef>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ // Run FQ
      if(p->state != RUNNABLE)
        continue;
80104c60:	90                   	nop
80104c61:	eb 04                	jmp    80104c67 <scheduler+0xef>
      if(p->usageCounter != 0) continue;  // Skip process if it has already used the FQ
80104c63:	90                   	nop
80104c64:	eb 01                	jmp    80104c67 <scheduler+0xef>
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
  
      if(p->pid == 5) continue;
80104c66:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ // Run FQ
80104c67:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104c6e:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
80104c75:	0f 82 24 ff ff ff    	jb     80104b9f <scheduler+0x27>
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ // Run AQ
80104c7b:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104c82:	e9 07 02 00 00       	jmp    80104e8e <scheduler+0x316>
      if(p->state != RUNNABLE)
80104c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8a:	8b 40 0c             	mov    0xc(%eax),%eax
80104c8d:	83 f8 03             	cmp    $0x3,%eax
80104c90:	0f 85 ed 01 00 00    	jne    80104e83 <scheduler+0x30b>
        continue;
      if(p->usageCounter == 0) continue;  // Skip process if it hasn't used the FQ
80104c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c99:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104c9f:	85 c0                	test   %eax,%eax
80104ca1:	0f 84 df 01 00 00    	je     80104e86 <scheduler+0x30e>
      
      p->usageCounter++;  // Add 1 to counter to keep processes from being locked out of the AQ
80104ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104caa:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104cb0:	8d 50 01             	lea    0x1(%eax),%edx
80104cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb6:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      if(strncmp(p->name, p->nameCopy, 16) != 0){ // Check if OS renamed an old process instead of allocating a new one
80104cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cbf:	8d 50 7c             	lea    0x7c(%eax),%edx
80104cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc5:	83 c0 6c             	add    $0x6c,%eax
80104cc8:	83 ec 04             	sub    $0x4,%esp
80104ccb:	6a 10                	push   $0x10
80104ccd:	52                   	push   %edx
80104cce:	50                   	push   %eax
80104ccf:	e8 d3 09 00 00       	call   801056a7 <strncmp>
80104cd4:	83 c4 10             	add    $0x10,%esp
80104cd7:	85 c0                	test   %eax,%eax
80104cd9:	0f 84 8e 01 00 00    	je     80104e6d <scheduler+0x2f5>
        p->usageCounter = 0;
80104cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce2:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80104ce9:	00 00 00 
        strncpy(p->nameCopy, p->name, 16);
80104cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cef:	8d 50 6c             	lea    0x6c(%eax),%edx
80104cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf5:	83 c0 7c             	add    $0x7c,%eax
80104cf8:	83 ec 04             	sub    $0x4,%esp
80104cfb:	6a 10                	push   $0x10
80104cfd:	52                   	push   %edx
80104cfe:	50                   	push   %eax
80104cff:	e8 f9 09 00 00       	call   801056fd <strncpy>
80104d04:	83 c4 10             	add    $0x10,%esp
      }
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.

      while(p->usageCounter % 4 != 0){ // Move to next process after current one has used 30ms
80104d07:	e9 61 01 00 00       	jmp    80104e6d <scheduler+0x2f5>
        for(q = ptable.proc; q < &ptable.proc[NPROC]; q++){ // Check FQ for added processes
80104d0c:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104d13:	e9 cf 00 00 00       	jmp    80104de7 <scheduler+0x26f>
          if(q->state != RUNNABLE)
80104d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d1b:	8b 40 0c             	mov    0xc(%eax),%eax
80104d1e:	83 f8 03             	cmp    $0x3,%eax
80104d21:	0f 85 b2 00 00 00    	jne    80104dd9 <scheduler+0x261>
           continue;
          if(q->usageCounter != 0) continue;  // Skip process if it has already used the FQ
80104d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d2a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104d30:	85 c0                	test   %eax,%eax
80104d32:	0f 85 a4 00 00 00    	jne    80104ddc <scheduler+0x264>
           strncpy(q->nameCopy, q->name, 16); // Make a copy of the process's current name
80104d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3b:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d41:	83 c0 7c             	add    $0x7c,%eax
80104d44:	83 ec 04             	sub    $0x4,%esp
80104d47:	6a 10                	push   $0x10
80104d49:	52                   	push   %edx
80104d4a:	50                   	push   %eax
80104d4b:	e8 ad 09 00 00       	call   801056fd <strncpy>
80104d50:	83 c4 10             	add    $0x10,%esp
          // Switch to chosen process.  It is the process's job
          // to release ptable.lock and then reacquire it
          // before jumping back to us.
          proc = q;
80104d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d56:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
          switchuvm(q);
80104d5c:	83 ec 0c             	sub    $0xc,%esp
80104d5f:	ff 75 f0             	pushl  -0x10(%ebp)
80104d62:	e8 71 33 00 00       	call   801080d8 <switchuvm>
80104d67:	83 c4 10             	add    $0x10,%esp
          q->state = RUNNING;
80104d6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d6d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
          if(q->pid == 5) continue;
80104d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d77:	8b 40 10             	mov    0x10(%eax),%eax
80104d7a:	83 f8 05             	cmp    $0x5,%eax
80104d7d:	74 60                	je     80104ddf <scheduler+0x267>
          swtch(&cpu->scheduler, proc->context);
80104d7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d85:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d88:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d8f:	83 c2 04             	add    $0x4,%edx
80104d92:	83 ec 08             	sub    $0x8,%esp
80104d95:	50                   	push   %eax
80104d96:	52                   	push   %edx
80104d97:	e8 2a 0a 00 00       	call   801057c6 <swtch>
80104d9c:	83 c4 10             	add    $0x10,%esp
          printQueue(q, "FQ");
80104d9f:	83 ec 08             	sub    $0x8,%esp
80104da2:	68 cf 8b 10 80       	push   $0x80108bcf
80104da7:	ff 75 f0             	pushl  -0x10(%ebp)
80104daa:	e8 a6 f6 ff ff       	call   80104455 <printQueue>
80104daf:	83 c4 10             	add    $0x10,%esp
          q->usageCounter++;  // Indicate that the process has used its time in the FQ
80104db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104dbb:	8d 50 01             	lea    0x1(%eax),%edx
80104dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc1:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
          switchkvm();
80104dc7:	e8 ef 32 00 00       	call   801080bb <switchkvm>

          // Process is done running for now.
          // It should have changed its p->state before coming back.
          proc = 0;
80104dcc:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104dd3:	00 00 00 00 
80104dd7:	eb 07                	jmp    80104de0 <scheduler+0x268>
      // before jumping back to us.

      while(p->usageCounter % 4 != 0){ // Move to next process after current one has used 30ms
        for(q = ptable.proc; q < &ptable.proc[NPROC]; q++){ // Check FQ for added processes
          if(q->state != RUNNABLE)
           continue;
80104dd9:	90                   	nop
80104dda:	eb 04                	jmp    80104de0 <scheduler+0x268>
          if(q->usageCounter != 0) continue;  // Skip process if it has already used the FQ
80104ddc:	90                   	nop
80104ddd:	eb 01                	jmp    80104de0 <scheduler+0x268>
          // to release ptable.lock and then reacquire it
          // before jumping back to us.
          proc = q;
          switchuvm(q);
          q->state = RUNNING;
          if(q->pid == 5) continue;
80104ddf:	90                   	nop
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.

      while(p->usageCounter % 4 != 0){ // Move to next process after current one has used 30ms
        for(q = ptable.proc; q < &ptable.proc[NPROC]; q++){ // Check FQ for added processes
80104de0:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
80104de7:	81 7d f0 94 4d 11 80 	cmpl   $0x80114d94,-0x10(%ebp)
80104dee:	0f 82 24 ff ff ff    	jb     80104d18 <scheduler+0x1a0>

          // Process is done running for now.
          // It should have changed its p->state before coming back.
          proc = 0;
        } 
        proc = p;
80104df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df7:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
        switchuvm(p);
80104dfd:	83 ec 0c             	sub    $0xc,%esp
80104e00:	ff 75 f4             	pushl  -0xc(%ebp)
80104e03:	e8 d0 32 00 00       	call   801080d8 <switchuvm>
80104e08:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
80104e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        swtch(&cpu->scheduler, proc->context);
80104e15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e1b:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e1e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104e25:	83 c2 04             	add    $0x4,%edx
80104e28:	83 ec 08             	sub    $0x8,%esp
80104e2b:	50                   	push   %eax
80104e2c:	52                   	push   %edx
80104e2d:	e8 94 09 00 00       	call   801057c6 <swtch>
80104e32:	83 c4 10             	add    $0x10,%esp
        printQueue(p, "AQ");
80104e35:	83 ec 08             	sub    $0x8,%esp
80104e38:	68 d2 8b 10 80       	push   $0x80108bd2
80104e3d:	ff 75 f4             	pushl  -0xc(%ebp)
80104e40:	e8 10 f6 ff ff       	call   80104455 <printQueue>
80104e45:	83 c4 10             	add    $0x10,%esp
        p->usageCounter++;
80104e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104e51:	8d 50 01             	lea    0x1(%eax),%edx
80104e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e57:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
        switchkvm();
80104e5d:	e8 59 32 00 00       	call   801080bb <switchkvm>
        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
80104e62:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104e69:	00 00 00 00 
      }
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.

      while(p->usageCounter % 4 != 0){ // Move to next process after current one has used 30ms
80104e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e70:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104e76:	83 e0 03             	and    $0x3,%eax
80104e79:	85 c0                	test   %eax,%eax
80104e7b:	0f 85 8b fe ff ff    	jne    80104d0c <scheduler+0x194>
80104e81:	eb 04                	jmp    80104e87 <scheduler+0x30f>
      proc = 0;
    }

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ // Run AQ
      if(p->state != RUNNABLE)
        continue;
80104e83:	90                   	nop
80104e84:	eb 01                	jmp    80104e87 <scheduler+0x30f>
      if(p->usageCounter == 0) continue;  // Skip process if it hasn't used the FQ
80104e86:	90                   	nop
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){ // Run AQ
80104e87:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104e8e:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
80104e95:	0f 82 ec fd ff ff    	jb     80104c87 <scheduler+0x10f>
        // It should have changed its p->state before coming back.
        proc = 0;
      };
      
    }
    release(&ptable.lock);
80104e9b:	83 ec 0c             	sub    $0xc,%esp
80104e9e:	68 60 29 11 80       	push   $0x80112960
80104ea3:	e8 ae 04 00 00       	call   80105356 <release>
80104ea8:	83 c4 10             	add    $0x10,%esp

  }
80104eab:	e9 ce fc ff ff       	jmp    80104b7e <scheduler+0x6>

80104eb0 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104eb0:	55                   	push   %ebp
80104eb1:	89 e5                	mov    %esp,%ebp
80104eb3:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104eb6:	83 ec 0c             	sub    $0xc,%esp
80104eb9:	68 60 29 11 80       	push   $0x80112960
80104ebe:	e8 5f 05 00 00       	call   80105422 <holding>
80104ec3:	83 c4 10             	add    $0x10,%esp
80104ec6:	85 c0                	test   %eax,%eax
80104ec8:	75 0d                	jne    80104ed7 <sched+0x27>
    panic("sched ptable.lock");
80104eca:	83 ec 0c             	sub    $0xc,%esp
80104ecd:	68 d5 8b 10 80       	push   $0x80108bd5
80104ed2:	e8 8f b6 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104ed7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104edd:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104ee3:	83 f8 01             	cmp    $0x1,%eax
80104ee6:	74 0d                	je     80104ef5 <sched+0x45>
    panic("sched locks");
80104ee8:	83 ec 0c             	sub    $0xc,%esp
80104eeb:	68 e7 8b 10 80       	push   $0x80108be7
80104ef0:	e8 71 b6 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104ef5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104efb:	8b 40 0c             	mov    0xc(%eax),%eax
80104efe:	83 f8 04             	cmp    $0x4,%eax
80104f01:	75 0d                	jne    80104f10 <sched+0x60>
    panic("sched running");
80104f03:	83 ec 0c             	sub    $0xc,%esp
80104f06:	68 f3 8b 10 80       	push   $0x80108bf3
80104f0b:	e8 56 b6 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104f10:	e8 29 f5 ff ff       	call   8010443e <readeflags>
80104f15:	25 00 02 00 00       	and    $0x200,%eax
80104f1a:	85 c0                	test   %eax,%eax
80104f1c:	74 0d                	je     80104f2b <sched+0x7b>
    panic("sched interruptible");
80104f1e:	83 ec 0c             	sub    $0xc,%esp
80104f21:	68 01 8c 10 80       	push   $0x80108c01
80104f26:	e8 3b b6 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104f2b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f31:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104f3a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f40:	8b 40 04             	mov    0x4(%eax),%eax
80104f43:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f4a:	83 c2 1c             	add    $0x1c,%edx
80104f4d:	83 ec 08             	sub    $0x8,%esp
80104f50:	50                   	push   %eax
80104f51:	52                   	push   %edx
80104f52:	e8 6f 08 00 00       	call   801057c6 <swtch>
80104f57:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104f5a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f63:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104f69:	90                   	nop
80104f6a:	c9                   	leave  
80104f6b:	c3                   	ret    

80104f6c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104f6c:	55                   	push   %ebp
80104f6d:	89 e5                	mov    %esp,%ebp
80104f6f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104f72:	83 ec 0c             	sub    $0xc,%esp
80104f75:	68 60 29 11 80       	push   $0x80112960
80104f7a:	e8 70 03 00 00       	call   801052ef <acquire>
80104f7f:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104f82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f88:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104f8f:	e8 1c ff ff ff       	call   80104eb0 <sched>
  release(&ptable.lock);
80104f94:	83 ec 0c             	sub    $0xc,%esp
80104f97:	68 60 29 11 80       	push   $0x80112960
80104f9c:	e8 b5 03 00 00       	call   80105356 <release>
80104fa1:	83 c4 10             	add    $0x10,%esp
}
80104fa4:	90                   	nop
80104fa5:	c9                   	leave  
80104fa6:	c3                   	ret    

80104fa7 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104fa7:	55                   	push   %ebp
80104fa8:	89 e5                	mov    %esp,%ebp
80104faa:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104fad:	83 ec 0c             	sub    $0xc,%esp
80104fb0:	68 60 29 11 80       	push   $0x80112960
80104fb5:	e8 9c 03 00 00       	call   80105356 <release>
80104fba:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104fbd:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104fc2:	85 c0                	test   %eax,%eax
80104fc4:	74 24                	je     80104fea <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104fc6:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104fcd:	00 00 00 
    iinit(ROOTDEV);
80104fd0:	83 ec 0c             	sub    $0xc,%esp
80104fd3:	6a 01                	push   $0x1
80104fd5:	e8 64 c6 ff ff       	call   8010163e <iinit>
80104fda:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104fdd:	83 ec 0c             	sub    $0xc,%esp
80104fe0:	6a 01                	push   $0x1
80104fe2:	e8 48 e3 ff ff       	call   8010332f <initlog>
80104fe7:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104fea:	90                   	nop
80104feb:	c9                   	leave  
80104fec:	c3                   	ret    

80104fed <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104fed:	55                   	push   %ebp
80104fee:	89 e5                	mov    %esp,%ebp
80104ff0:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104ff3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff9:	85 c0                	test   %eax,%eax
80104ffb:	75 0d                	jne    8010500a <sleep+0x1d>
    panic("sleep");
80104ffd:	83 ec 0c             	sub    $0xc,%esp
80105000:	68 15 8c 10 80       	push   $0x80108c15
80105005:	e8 5c b5 ff ff       	call   80100566 <panic>

  if(lk == 0)
8010500a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010500e:	75 0d                	jne    8010501d <sleep+0x30>
    panic("sleep without lk");
80105010:	83 ec 0c             	sub    $0xc,%esp
80105013:	68 1b 8c 10 80       	push   $0x80108c1b
80105018:	e8 49 b5 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010501d:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80105024:	74 1e                	je     80105044 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105026:	83 ec 0c             	sub    $0xc,%esp
80105029:	68 60 29 11 80       	push   $0x80112960
8010502e:	e8 bc 02 00 00       	call   801052ef <acquire>
80105033:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105036:	83 ec 0c             	sub    $0xc,%esp
80105039:	ff 75 0c             	pushl  0xc(%ebp)
8010503c:	e8 15 03 00 00       	call   80105356 <release>
80105041:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105044:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010504a:	8b 55 08             	mov    0x8(%ebp),%edx
8010504d:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105050:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105056:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010505d:	e8 4e fe ff ff       	call   80104eb0 <sched>

  // Tidy up.
  proc->chan = 0;
80105062:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105068:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010506f:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80105076:	74 1e                	je     80105096 <sleep+0xa9>
    release(&ptable.lock);
80105078:	83 ec 0c             	sub    $0xc,%esp
8010507b:	68 60 29 11 80       	push   $0x80112960
80105080:	e8 d1 02 00 00       	call   80105356 <release>
80105085:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105088:	83 ec 0c             	sub    $0xc,%esp
8010508b:	ff 75 0c             	pushl  0xc(%ebp)
8010508e:	e8 5c 02 00 00       	call   801052ef <acquire>
80105093:	83 c4 10             	add    $0x10,%esp
  }
}
80105096:	90                   	nop
80105097:	c9                   	leave  
80105098:	c3                   	ret    

80105099 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105099:	55                   	push   %ebp
8010509a:	89 e5                	mov    %esp,%ebp
8010509c:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010509f:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
801050a6:	eb 27                	jmp    801050cf <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801050a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ab:	8b 40 0c             	mov    0xc(%eax),%eax
801050ae:	83 f8 02             	cmp    $0x2,%eax
801050b1:	75 15                	jne    801050c8 <wakeup1+0x2f>
801050b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050b6:	8b 40 20             	mov    0x20(%eax),%eax
801050b9:	3b 45 08             	cmp    0x8(%ebp),%eax
801050bc:	75 0a                	jne    801050c8 <wakeup1+0x2f>
      p->state = RUNNABLE;
801050be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050c1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050c8:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
801050cf:	81 7d fc 94 4d 11 80 	cmpl   $0x80114d94,-0x4(%ebp)
801050d6:	72 d0                	jb     801050a8 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801050d8:	90                   	nop
801050d9:	c9                   	leave  
801050da:	c3                   	ret    

801050db <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801050db:	55                   	push   %ebp
801050dc:	89 e5                	mov    %esp,%ebp
801050de:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801050e1:	83 ec 0c             	sub    $0xc,%esp
801050e4:	68 60 29 11 80       	push   $0x80112960
801050e9:	e8 01 02 00 00       	call   801052ef <acquire>
801050ee:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801050f1:	83 ec 0c             	sub    $0xc,%esp
801050f4:	ff 75 08             	pushl  0x8(%ebp)
801050f7:	e8 9d ff ff ff       	call   80105099 <wakeup1>
801050fc:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801050ff:	83 ec 0c             	sub    $0xc,%esp
80105102:	68 60 29 11 80       	push   $0x80112960
80105107:	e8 4a 02 00 00       	call   80105356 <release>
8010510c:	83 c4 10             	add    $0x10,%esp
}
8010510f:	90                   	nop
80105110:	c9                   	leave  
80105111:	c3                   	ret    

80105112 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105112:	55                   	push   %ebp
80105113:	89 e5                	mov    %esp,%ebp
80105115:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105118:	83 ec 0c             	sub    $0xc,%esp
8010511b:	68 60 29 11 80       	push   $0x80112960
80105120:	e8 ca 01 00 00       	call   801052ef <acquire>
80105125:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105128:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
8010512f:	eb 48                	jmp    80105179 <kill+0x67>
    if(p->pid == pid){
80105131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105134:	8b 40 10             	mov    0x10(%eax),%eax
80105137:	3b 45 08             	cmp    0x8(%ebp),%eax
8010513a:	75 36                	jne    80105172 <kill+0x60>
      p->killed = 1;
8010513c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105149:	8b 40 0c             	mov    0xc(%eax),%eax
8010514c:	83 f8 02             	cmp    $0x2,%eax
8010514f:	75 0a                	jne    8010515b <kill+0x49>
        p->state = RUNNABLE;
80105151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105154:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010515b:	83 ec 0c             	sub    $0xc,%esp
8010515e:	68 60 29 11 80       	push   $0x80112960
80105163:	e8 ee 01 00 00       	call   80105356 <release>
80105168:	83 c4 10             	add    $0x10,%esp
      return 0;
8010516b:	b8 00 00 00 00       	mov    $0x0,%eax
80105170:	eb 25                	jmp    80105197 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105172:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80105179:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
80105180:	72 af                	jb     80105131 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105182:	83 ec 0c             	sub    $0xc,%esp
80105185:	68 60 29 11 80       	push   $0x80112960
8010518a:	e8 c7 01 00 00       	call   80105356 <release>
8010518f:	83 c4 10             	add    $0x10,%esp
  return -1;
80105192:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105197:	c9                   	leave  
80105198:	c3                   	ret    

80105199 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105199:	55                   	push   %ebp
8010519a:	89 e5                	mov    %esp,%ebp
8010519c:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010519f:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
801051a6:	e9 da 00 00 00       	jmp    80105285 <procdump+0xec>
    if(p->state == UNUSED)
801051ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ae:	8b 40 0c             	mov    0xc(%eax),%eax
801051b1:	85 c0                	test   %eax,%eax
801051b3:	0f 84 c4 00 00 00    	je     8010527d <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801051b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051bc:	8b 40 0c             	mov    0xc(%eax),%eax
801051bf:	83 f8 05             	cmp    $0x5,%eax
801051c2:	77 23                	ja     801051e7 <procdump+0x4e>
801051c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051c7:	8b 40 0c             	mov    0xc(%eax),%eax
801051ca:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
801051d1:	85 c0                	test   %eax,%eax
801051d3:	74 12                	je     801051e7 <procdump+0x4e>
      state = states[p->state];
801051d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d8:	8b 40 0c             	mov    0xc(%eax),%eax
801051db:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
801051e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801051e5:	eb 07                	jmp    801051ee <procdump+0x55>
    else
      state = "???";
801051e7:	c7 45 ec 2c 8c 10 80 	movl   $0x80108c2c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801051ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f1:	8d 50 6c             	lea    0x6c(%eax),%edx
801051f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f7:	8b 40 10             	mov    0x10(%eax),%eax
801051fa:	52                   	push   %edx
801051fb:	ff 75 ec             	pushl  -0x14(%ebp)
801051fe:	50                   	push   %eax
801051ff:	68 30 8c 10 80       	push   $0x80108c30
80105204:	e8 bd b1 ff ff       	call   801003c6 <cprintf>
80105209:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010520c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010520f:	8b 40 0c             	mov    0xc(%eax),%eax
80105212:	83 f8 02             	cmp    $0x2,%eax
80105215:	75 54                	jne    8010526b <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105217:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010521d:	8b 40 0c             	mov    0xc(%eax),%eax
80105220:	83 c0 08             	add    $0x8,%eax
80105223:	89 c2                	mov    %eax,%edx
80105225:	83 ec 08             	sub    $0x8,%esp
80105228:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010522b:	50                   	push   %eax
8010522c:	52                   	push   %edx
8010522d:	e8 76 01 00 00       	call   801053a8 <getcallerpcs>
80105232:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105235:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010523c:	eb 1c                	jmp    8010525a <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010523e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105241:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105245:	83 ec 08             	sub    $0x8,%esp
80105248:	50                   	push   %eax
80105249:	68 39 8c 10 80       	push   $0x80108c39
8010524e:	e8 73 b1 ff ff       	call   801003c6 <cprintf>
80105253:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105256:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010525a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010525e:	7f 0b                	jg     8010526b <procdump+0xd2>
80105260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105263:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105267:	85 c0                	test   %eax,%eax
80105269:	75 d3                	jne    8010523e <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010526b:	83 ec 0c             	sub    $0xc,%esp
8010526e:	68 3d 8c 10 80       	push   $0x80108c3d
80105273:	e8 4e b1 ff ff       	call   801003c6 <cprintf>
80105278:	83 c4 10             	add    $0x10,%esp
8010527b:	eb 01                	jmp    8010527e <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
8010527d:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010527e:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
80105285:	81 7d f0 94 4d 11 80 	cmpl   $0x80114d94,-0x10(%ebp)
8010528c:	0f 82 19 ff ff ff    	jb     801051ab <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105292:	90                   	nop
80105293:	c9                   	leave  
80105294:	c3                   	ret    

80105295 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105295:	55                   	push   %ebp
80105296:	89 e5                	mov    %esp,%ebp
80105298:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010529b:	9c                   	pushf  
8010529c:	58                   	pop    %eax
8010529d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801052a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052a3:	c9                   	leave  
801052a4:	c3                   	ret    

801052a5 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801052a5:	55                   	push   %ebp
801052a6:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801052a8:	fa                   	cli    
}
801052a9:	90                   	nop
801052aa:	5d                   	pop    %ebp
801052ab:	c3                   	ret    

801052ac <sti>:

static inline void
sti(void)
{
801052ac:	55                   	push   %ebp
801052ad:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801052af:	fb                   	sti    
}
801052b0:	90                   	nop
801052b1:	5d                   	pop    %ebp
801052b2:	c3                   	ret    

801052b3 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801052b3:	55                   	push   %ebp
801052b4:	89 e5                	mov    %esp,%ebp
801052b6:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801052b9:	8b 55 08             	mov    0x8(%ebp),%edx
801052bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801052bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052c2:	f0 87 02             	lock xchg %eax,(%edx)
801052c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801052c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052cb:	c9                   	leave  
801052cc:	c3                   	ret    

801052cd <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052cd:	55                   	push   %ebp
801052ce:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052d0:	8b 45 08             	mov    0x8(%ebp),%eax
801052d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801052d6:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052d9:	8b 45 08             	mov    0x8(%ebp),%eax
801052dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052e2:	8b 45 08             	mov    0x8(%ebp),%eax
801052e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052ec:	90                   	nop
801052ed:	5d                   	pop    %ebp
801052ee:	c3                   	ret    

801052ef <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052ef:	55                   	push   %ebp
801052f0:	89 e5                	mov    %esp,%ebp
801052f2:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052f5:	e8 52 01 00 00       	call   8010544c <pushcli>
  if(holding(lk))
801052fa:	8b 45 08             	mov    0x8(%ebp),%eax
801052fd:	83 ec 0c             	sub    $0xc,%esp
80105300:	50                   	push   %eax
80105301:	e8 1c 01 00 00       	call   80105422 <holding>
80105306:	83 c4 10             	add    $0x10,%esp
80105309:	85 c0                	test   %eax,%eax
8010530b:	74 0d                	je     8010531a <acquire+0x2b>
    panic("acquire");
8010530d:	83 ec 0c             	sub    $0xc,%esp
80105310:	68 69 8c 10 80       	push   $0x80108c69
80105315:	e8 4c b2 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010531a:	90                   	nop
8010531b:	8b 45 08             	mov    0x8(%ebp),%eax
8010531e:	83 ec 08             	sub    $0x8,%esp
80105321:	6a 01                	push   $0x1
80105323:	50                   	push   %eax
80105324:	e8 8a ff ff ff       	call   801052b3 <xchg>
80105329:	83 c4 10             	add    $0x10,%esp
8010532c:	85 c0                	test   %eax,%eax
8010532e:	75 eb                	jne    8010531b <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105330:	8b 45 08             	mov    0x8(%ebp),%eax
80105333:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010533a:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010533d:	8b 45 08             	mov    0x8(%ebp),%eax
80105340:	83 c0 0c             	add    $0xc,%eax
80105343:	83 ec 08             	sub    $0x8,%esp
80105346:	50                   	push   %eax
80105347:	8d 45 08             	lea    0x8(%ebp),%eax
8010534a:	50                   	push   %eax
8010534b:	e8 58 00 00 00       	call   801053a8 <getcallerpcs>
80105350:	83 c4 10             	add    $0x10,%esp
}
80105353:	90                   	nop
80105354:	c9                   	leave  
80105355:	c3                   	ret    

80105356 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105356:	55                   	push   %ebp
80105357:	89 e5                	mov    %esp,%ebp
80105359:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010535c:	83 ec 0c             	sub    $0xc,%esp
8010535f:	ff 75 08             	pushl  0x8(%ebp)
80105362:	e8 bb 00 00 00       	call   80105422 <holding>
80105367:	83 c4 10             	add    $0x10,%esp
8010536a:	85 c0                	test   %eax,%eax
8010536c:	75 0d                	jne    8010537b <release+0x25>
    panic("release");
8010536e:	83 ec 0c             	sub    $0xc,%esp
80105371:	68 71 8c 10 80       	push   $0x80108c71
80105376:	e8 eb b1 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
8010537b:	8b 45 08             	mov    0x8(%ebp),%eax
8010537e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105385:	8b 45 08             	mov    0x8(%ebp),%eax
80105388:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010538f:	8b 45 08             	mov    0x8(%ebp),%eax
80105392:	83 ec 08             	sub    $0x8,%esp
80105395:	6a 00                	push   $0x0
80105397:	50                   	push   %eax
80105398:	e8 16 ff ff ff       	call   801052b3 <xchg>
8010539d:	83 c4 10             	add    $0x10,%esp

  popcli();
801053a0:	e8 ec 00 00 00       	call   80105491 <popcli>
}
801053a5:	90                   	nop
801053a6:	c9                   	leave  
801053a7:	c3                   	ret    

801053a8 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801053a8:	55                   	push   %ebp
801053a9:	89 e5                	mov    %esp,%ebp
801053ab:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801053ae:	8b 45 08             	mov    0x8(%ebp),%eax
801053b1:	83 e8 08             	sub    $0x8,%eax
801053b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053b7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801053be:	eb 38                	jmp    801053f8 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053c0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053c4:	74 53                	je     80105419 <getcallerpcs+0x71>
801053c6:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053cd:	76 4a                	jbe    80105419 <getcallerpcs+0x71>
801053cf:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053d3:	74 44                	je     80105419 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053df:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e2:	01 c2                	add    %eax,%edx
801053e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e7:	8b 40 04             	mov    0x4(%eax),%eax
801053ea:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801053ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ef:	8b 00                	mov    (%eax),%eax
801053f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801053f4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053f8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053fc:	7e c2                	jle    801053c0 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053fe:	eb 19                	jmp    80105419 <getcallerpcs+0x71>
    pcs[i] = 0;
80105400:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105403:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010540a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010540d:	01 d0                	add    %edx,%eax
8010540f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105415:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105419:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010541d:	7e e1                	jle    80105400 <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010541f:	90                   	nop
80105420:	c9                   	leave  
80105421:	c3                   	ret    

80105422 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105422:	55                   	push   %ebp
80105423:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105425:	8b 45 08             	mov    0x8(%ebp),%eax
80105428:	8b 00                	mov    (%eax),%eax
8010542a:	85 c0                	test   %eax,%eax
8010542c:	74 17                	je     80105445 <holding+0x23>
8010542e:	8b 45 08             	mov    0x8(%ebp),%eax
80105431:	8b 50 08             	mov    0x8(%eax),%edx
80105434:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010543a:	39 c2                	cmp    %eax,%edx
8010543c:	75 07                	jne    80105445 <holding+0x23>
8010543e:	b8 01 00 00 00       	mov    $0x1,%eax
80105443:	eb 05                	jmp    8010544a <holding+0x28>
80105445:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010544a:	5d                   	pop    %ebp
8010544b:	c3                   	ret    

8010544c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010544c:	55                   	push   %ebp
8010544d:	89 e5                	mov    %esp,%ebp
8010544f:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105452:	e8 3e fe ff ff       	call   80105295 <readeflags>
80105457:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010545a:	e8 46 fe ff ff       	call   801052a5 <cli>
  if(cpu->ncli++ == 0)
8010545f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105466:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
8010546c:	8d 48 01             	lea    0x1(%eax),%ecx
8010546f:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105475:	85 c0                	test   %eax,%eax
80105477:	75 15                	jne    8010548e <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105479:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010547f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105482:	81 e2 00 02 00 00    	and    $0x200,%edx
80105488:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010548e:	90                   	nop
8010548f:	c9                   	leave  
80105490:	c3                   	ret    

80105491 <popcli>:

void
popcli(void)
{
80105491:	55                   	push   %ebp
80105492:	89 e5                	mov    %esp,%ebp
80105494:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105497:	e8 f9 fd ff ff       	call   80105295 <readeflags>
8010549c:	25 00 02 00 00       	and    $0x200,%eax
801054a1:	85 c0                	test   %eax,%eax
801054a3:	74 0d                	je     801054b2 <popcli+0x21>
    panic("popcli - interruptible");
801054a5:	83 ec 0c             	sub    $0xc,%esp
801054a8:	68 79 8c 10 80       	push   $0x80108c79
801054ad:	e8 b4 b0 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
801054b2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054b8:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801054be:	83 ea 01             	sub    $0x1,%edx
801054c1:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801054c7:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801054cd:	85 c0                	test   %eax,%eax
801054cf:	79 0d                	jns    801054de <popcli+0x4d>
    panic("popcli");
801054d1:	83 ec 0c             	sub    $0xc,%esp
801054d4:	68 90 8c 10 80       	push   $0x80108c90
801054d9:	e8 88 b0 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801054de:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054e4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801054ea:	85 c0                	test   %eax,%eax
801054ec:	75 15                	jne    80105503 <popcli+0x72>
801054ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054f4:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801054fa:	85 c0                	test   %eax,%eax
801054fc:	74 05                	je     80105503 <popcli+0x72>
    sti();
801054fe:	e8 a9 fd ff ff       	call   801052ac <sti>
}
80105503:	90                   	nop
80105504:	c9                   	leave  
80105505:	c3                   	ret    

80105506 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105506:	55                   	push   %ebp
80105507:	89 e5                	mov    %esp,%ebp
80105509:	57                   	push   %edi
8010550a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010550b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010550e:	8b 55 10             	mov    0x10(%ebp),%edx
80105511:	8b 45 0c             	mov    0xc(%ebp),%eax
80105514:	89 cb                	mov    %ecx,%ebx
80105516:	89 df                	mov    %ebx,%edi
80105518:	89 d1                	mov    %edx,%ecx
8010551a:	fc                   	cld    
8010551b:	f3 aa                	rep stos %al,%es:(%edi)
8010551d:	89 ca                	mov    %ecx,%edx
8010551f:	89 fb                	mov    %edi,%ebx
80105521:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105524:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105527:	90                   	nop
80105528:	5b                   	pop    %ebx
80105529:	5f                   	pop    %edi
8010552a:	5d                   	pop    %ebp
8010552b:	c3                   	ret    

8010552c <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010552c:	55                   	push   %ebp
8010552d:	89 e5                	mov    %esp,%ebp
8010552f:	57                   	push   %edi
80105530:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105531:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105534:	8b 55 10             	mov    0x10(%ebp),%edx
80105537:	8b 45 0c             	mov    0xc(%ebp),%eax
8010553a:	89 cb                	mov    %ecx,%ebx
8010553c:	89 df                	mov    %ebx,%edi
8010553e:	89 d1                	mov    %edx,%ecx
80105540:	fc                   	cld    
80105541:	f3 ab                	rep stos %eax,%es:(%edi)
80105543:	89 ca                	mov    %ecx,%edx
80105545:	89 fb                	mov    %edi,%ebx
80105547:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010554a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010554d:	90                   	nop
8010554e:	5b                   	pop    %ebx
8010554f:	5f                   	pop    %edi
80105550:	5d                   	pop    %ebp
80105551:	c3                   	ret    

80105552 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105552:	55                   	push   %ebp
80105553:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105555:	8b 45 08             	mov    0x8(%ebp),%eax
80105558:	83 e0 03             	and    $0x3,%eax
8010555b:	85 c0                	test   %eax,%eax
8010555d:	75 43                	jne    801055a2 <memset+0x50>
8010555f:	8b 45 10             	mov    0x10(%ebp),%eax
80105562:	83 e0 03             	and    $0x3,%eax
80105565:	85 c0                	test   %eax,%eax
80105567:	75 39                	jne    801055a2 <memset+0x50>
    c &= 0xFF;
80105569:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105570:	8b 45 10             	mov    0x10(%ebp),%eax
80105573:	c1 e8 02             	shr    $0x2,%eax
80105576:	89 c1                	mov    %eax,%ecx
80105578:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557b:	c1 e0 18             	shl    $0x18,%eax
8010557e:	89 c2                	mov    %eax,%edx
80105580:	8b 45 0c             	mov    0xc(%ebp),%eax
80105583:	c1 e0 10             	shl    $0x10,%eax
80105586:	09 c2                	or     %eax,%edx
80105588:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558b:	c1 e0 08             	shl    $0x8,%eax
8010558e:	09 d0                	or     %edx,%eax
80105590:	0b 45 0c             	or     0xc(%ebp),%eax
80105593:	51                   	push   %ecx
80105594:	50                   	push   %eax
80105595:	ff 75 08             	pushl  0x8(%ebp)
80105598:	e8 8f ff ff ff       	call   8010552c <stosl>
8010559d:	83 c4 0c             	add    $0xc,%esp
801055a0:	eb 12                	jmp    801055b4 <memset+0x62>
  } else
    stosb(dst, c, n);
801055a2:	8b 45 10             	mov    0x10(%ebp),%eax
801055a5:	50                   	push   %eax
801055a6:	ff 75 0c             	pushl  0xc(%ebp)
801055a9:	ff 75 08             	pushl  0x8(%ebp)
801055ac:	e8 55 ff ff ff       	call   80105506 <stosb>
801055b1:	83 c4 0c             	add    $0xc,%esp
  return dst;
801055b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055b7:	c9                   	leave  
801055b8:	c3                   	ret    

801055b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801055b9:	55                   	push   %ebp
801055ba:	89 e5                	mov    %esp,%ebp
801055bc:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801055bf:	8b 45 08             	mov    0x8(%ebp),%eax
801055c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055cb:	eb 30                	jmp    801055fd <memcmp+0x44>
    if(*s1 != *s2)
801055cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055d0:	0f b6 10             	movzbl (%eax),%edx
801055d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055d6:	0f b6 00             	movzbl (%eax),%eax
801055d9:	38 c2                	cmp    %al,%dl
801055db:	74 18                	je     801055f5 <memcmp+0x3c>
      return *s1 - *s2;
801055dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e0:	0f b6 00             	movzbl (%eax),%eax
801055e3:	0f b6 d0             	movzbl %al,%edx
801055e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055e9:	0f b6 00             	movzbl (%eax),%eax
801055ec:	0f b6 c0             	movzbl %al,%eax
801055ef:	29 c2                	sub    %eax,%edx
801055f1:	89 d0                	mov    %edx,%eax
801055f3:	eb 1a                	jmp    8010560f <memcmp+0x56>
    s1++, s2++;
801055f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055f9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801055fd:	8b 45 10             	mov    0x10(%ebp),%eax
80105600:	8d 50 ff             	lea    -0x1(%eax),%edx
80105603:	89 55 10             	mov    %edx,0x10(%ebp)
80105606:	85 c0                	test   %eax,%eax
80105608:	75 c3                	jne    801055cd <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010560a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010560f:	c9                   	leave  
80105610:	c3                   	ret    

80105611 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105611:	55                   	push   %ebp
80105612:	89 e5                	mov    %esp,%ebp
80105614:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105617:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010561d:	8b 45 08             	mov    0x8(%ebp),%eax
80105620:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105623:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105626:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105629:	73 54                	jae    8010567f <memmove+0x6e>
8010562b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010562e:	8b 45 10             	mov    0x10(%ebp),%eax
80105631:	01 d0                	add    %edx,%eax
80105633:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105636:	76 47                	jbe    8010567f <memmove+0x6e>
    s += n;
80105638:	8b 45 10             	mov    0x10(%ebp),%eax
8010563b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010563e:	8b 45 10             	mov    0x10(%ebp),%eax
80105641:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105644:	eb 13                	jmp    80105659 <memmove+0x48>
      *--d = *--s;
80105646:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010564a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010564e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105651:	0f b6 10             	movzbl (%eax),%edx
80105654:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105657:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105659:	8b 45 10             	mov    0x10(%ebp),%eax
8010565c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010565f:	89 55 10             	mov    %edx,0x10(%ebp)
80105662:	85 c0                	test   %eax,%eax
80105664:	75 e0                	jne    80105646 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105666:	eb 24                	jmp    8010568c <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105668:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010566b:	8d 50 01             	lea    0x1(%eax),%edx
8010566e:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105671:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105674:	8d 4a 01             	lea    0x1(%edx),%ecx
80105677:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010567a:	0f b6 12             	movzbl (%edx),%edx
8010567d:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010567f:	8b 45 10             	mov    0x10(%ebp),%eax
80105682:	8d 50 ff             	lea    -0x1(%eax),%edx
80105685:	89 55 10             	mov    %edx,0x10(%ebp)
80105688:	85 c0                	test   %eax,%eax
8010568a:	75 dc                	jne    80105668 <memmove+0x57>
      *d++ = *s++;

  return dst;
8010568c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010568f:	c9                   	leave  
80105690:	c3                   	ret    

80105691 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105691:	55                   	push   %ebp
80105692:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105694:	ff 75 10             	pushl  0x10(%ebp)
80105697:	ff 75 0c             	pushl  0xc(%ebp)
8010569a:	ff 75 08             	pushl  0x8(%ebp)
8010569d:	e8 6f ff ff ff       	call   80105611 <memmove>
801056a2:	83 c4 0c             	add    $0xc,%esp
}
801056a5:	c9                   	leave  
801056a6:	c3                   	ret    

801056a7 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801056a7:	55                   	push   %ebp
801056a8:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056aa:	eb 0c                	jmp    801056b8 <strncmp+0x11>
    n--, p++, q++;
801056ac:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056b4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801056b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056bc:	74 1a                	je     801056d8 <strncmp+0x31>
801056be:	8b 45 08             	mov    0x8(%ebp),%eax
801056c1:	0f b6 00             	movzbl (%eax),%eax
801056c4:	84 c0                	test   %al,%al
801056c6:	74 10                	je     801056d8 <strncmp+0x31>
801056c8:	8b 45 08             	mov    0x8(%ebp),%eax
801056cb:	0f b6 10             	movzbl (%eax),%edx
801056ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d1:	0f b6 00             	movzbl (%eax),%eax
801056d4:	38 c2                	cmp    %al,%dl
801056d6:	74 d4                	je     801056ac <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801056d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056dc:	75 07                	jne    801056e5 <strncmp+0x3e>
    return 0;
801056de:	b8 00 00 00 00       	mov    $0x0,%eax
801056e3:	eb 16                	jmp    801056fb <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801056e5:	8b 45 08             	mov    0x8(%ebp),%eax
801056e8:	0f b6 00             	movzbl (%eax),%eax
801056eb:	0f b6 d0             	movzbl %al,%edx
801056ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f1:	0f b6 00             	movzbl (%eax),%eax
801056f4:	0f b6 c0             	movzbl %al,%eax
801056f7:	29 c2                	sub    %eax,%edx
801056f9:	89 d0                	mov    %edx,%eax
}
801056fb:	5d                   	pop    %ebp
801056fc:	c3                   	ret    

801056fd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056fd:	55                   	push   %ebp
801056fe:	89 e5                	mov    %esp,%ebp
80105700:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105703:	8b 45 08             	mov    0x8(%ebp),%eax
80105706:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105709:	90                   	nop
8010570a:	8b 45 10             	mov    0x10(%ebp),%eax
8010570d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105710:	89 55 10             	mov    %edx,0x10(%ebp)
80105713:	85 c0                	test   %eax,%eax
80105715:	7e 2c                	jle    80105743 <strncpy+0x46>
80105717:	8b 45 08             	mov    0x8(%ebp),%eax
8010571a:	8d 50 01             	lea    0x1(%eax),%edx
8010571d:	89 55 08             	mov    %edx,0x8(%ebp)
80105720:	8b 55 0c             	mov    0xc(%ebp),%edx
80105723:	8d 4a 01             	lea    0x1(%edx),%ecx
80105726:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105729:	0f b6 12             	movzbl (%edx),%edx
8010572c:	88 10                	mov    %dl,(%eax)
8010572e:	0f b6 00             	movzbl (%eax),%eax
80105731:	84 c0                	test   %al,%al
80105733:	75 d5                	jne    8010570a <strncpy+0xd>
    ;
  while(n-- > 0)
80105735:	eb 0c                	jmp    80105743 <strncpy+0x46>
    *s++ = 0;
80105737:	8b 45 08             	mov    0x8(%ebp),%eax
8010573a:	8d 50 01             	lea    0x1(%eax),%edx
8010573d:	89 55 08             	mov    %edx,0x8(%ebp)
80105740:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105743:	8b 45 10             	mov    0x10(%ebp),%eax
80105746:	8d 50 ff             	lea    -0x1(%eax),%edx
80105749:	89 55 10             	mov    %edx,0x10(%ebp)
8010574c:	85 c0                	test   %eax,%eax
8010574e:	7f e7                	jg     80105737 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105750:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105753:	c9                   	leave  
80105754:	c3                   	ret    

80105755 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105755:	55                   	push   %ebp
80105756:	89 e5                	mov    %esp,%ebp
80105758:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010575b:	8b 45 08             	mov    0x8(%ebp),%eax
8010575e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105761:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105765:	7f 05                	jg     8010576c <safestrcpy+0x17>
    return os;
80105767:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010576a:	eb 31                	jmp    8010579d <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010576c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105770:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105774:	7e 1e                	jle    80105794 <safestrcpy+0x3f>
80105776:	8b 45 08             	mov    0x8(%ebp),%eax
80105779:	8d 50 01             	lea    0x1(%eax),%edx
8010577c:	89 55 08             	mov    %edx,0x8(%ebp)
8010577f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105782:	8d 4a 01             	lea    0x1(%edx),%ecx
80105785:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105788:	0f b6 12             	movzbl (%edx),%edx
8010578b:	88 10                	mov    %dl,(%eax)
8010578d:	0f b6 00             	movzbl (%eax),%eax
80105790:	84 c0                	test   %al,%al
80105792:	75 d8                	jne    8010576c <safestrcpy+0x17>
    ;
  *s = 0;
80105794:	8b 45 08             	mov    0x8(%ebp),%eax
80105797:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010579a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010579d:	c9                   	leave  
8010579e:	c3                   	ret    

8010579f <strlen>:

int
strlen(const char *s)
{
8010579f:	55                   	push   %ebp
801057a0:	89 e5                	mov    %esp,%ebp
801057a2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057ac:	eb 04                	jmp    801057b2 <strlen+0x13>
801057ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b5:	8b 45 08             	mov    0x8(%ebp),%eax
801057b8:	01 d0                	add    %edx,%eax
801057ba:	0f b6 00             	movzbl (%eax),%eax
801057bd:	84 c0                	test   %al,%al
801057bf:	75 ed                	jne    801057ae <strlen+0xf>
    ;
  return n;
801057c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057c4:	c9                   	leave  
801057c5:	c3                   	ret    

801057c6 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801057c6:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801057ca:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801057ce:	55                   	push   %ebp
  pushl %ebx
801057cf:	53                   	push   %ebx
  pushl %esi
801057d0:	56                   	push   %esi
  pushl %edi
801057d1:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801057d2:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801057d4:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801057d6:	5f                   	pop    %edi
  popl %esi
801057d7:	5e                   	pop    %esi
  popl %ebx
801057d8:	5b                   	pop    %ebx
  popl %ebp
801057d9:	5d                   	pop    %ebp
  ret
801057da:	c3                   	ret    

801057db <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801057db:	55                   	push   %ebp
801057dc:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801057de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057e4:	8b 00                	mov    (%eax),%eax
801057e6:	3b 45 08             	cmp    0x8(%ebp),%eax
801057e9:	76 12                	jbe    801057fd <fetchint+0x22>
801057eb:	8b 45 08             	mov    0x8(%ebp),%eax
801057ee:	8d 50 04             	lea    0x4(%eax),%edx
801057f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057f7:	8b 00                	mov    (%eax),%eax
801057f9:	39 c2                	cmp    %eax,%edx
801057fb:	76 07                	jbe    80105804 <fetchint+0x29>
    return -1;
801057fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105802:	eb 0f                	jmp    80105813 <fetchint+0x38>
  *ip = *(int*)(addr);
80105804:	8b 45 08             	mov    0x8(%ebp),%eax
80105807:	8b 10                	mov    (%eax),%edx
80105809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010580c:	89 10                	mov    %edx,(%eax)
  return 0;
8010580e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105813:	5d                   	pop    %ebp
80105814:	c3                   	ret    

80105815 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105815:	55                   	push   %ebp
80105816:	89 e5                	mov    %esp,%ebp
80105818:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010581b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105821:	8b 00                	mov    (%eax),%eax
80105823:	3b 45 08             	cmp    0x8(%ebp),%eax
80105826:	77 07                	ja     8010582f <fetchstr+0x1a>
    return -1;
80105828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582d:	eb 46                	jmp    80105875 <fetchstr+0x60>
  *pp = (char*)addr;
8010582f:	8b 55 08             	mov    0x8(%ebp),%edx
80105832:	8b 45 0c             	mov    0xc(%ebp),%eax
80105835:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105837:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010583d:	8b 00                	mov    (%eax),%eax
8010583f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105842:	8b 45 0c             	mov    0xc(%ebp),%eax
80105845:	8b 00                	mov    (%eax),%eax
80105847:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010584a:	eb 1c                	jmp    80105868 <fetchstr+0x53>
    if(*s == 0)
8010584c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010584f:	0f b6 00             	movzbl (%eax),%eax
80105852:	84 c0                	test   %al,%al
80105854:	75 0e                	jne    80105864 <fetchstr+0x4f>
      return s - *pp;
80105856:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105859:	8b 45 0c             	mov    0xc(%ebp),%eax
8010585c:	8b 00                	mov    (%eax),%eax
8010585e:	29 c2                	sub    %eax,%edx
80105860:	89 d0                	mov    %edx,%eax
80105862:	eb 11                	jmp    80105875 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105864:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105868:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010586b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010586e:	72 dc                	jb     8010584c <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105870:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105875:	c9                   	leave  
80105876:	c3                   	ret    

80105877 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105877:	55                   	push   %ebp
80105878:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010587a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105880:	8b 40 18             	mov    0x18(%eax),%eax
80105883:	8b 40 44             	mov    0x44(%eax),%eax
80105886:	8b 55 08             	mov    0x8(%ebp),%edx
80105889:	c1 e2 02             	shl    $0x2,%edx
8010588c:	01 d0                	add    %edx,%eax
8010588e:	83 c0 04             	add    $0x4,%eax
80105891:	ff 75 0c             	pushl  0xc(%ebp)
80105894:	50                   	push   %eax
80105895:	e8 41 ff ff ff       	call   801057db <fetchint>
8010589a:	83 c4 08             	add    $0x8,%esp
}
8010589d:	c9                   	leave  
8010589e:	c3                   	ret    

8010589f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010589f:	55                   	push   %ebp
801058a0:	89 e5                	mov    %esp,%ebp
801058a2:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801058a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
801058a8:	50                   	push   %eax
801058a9:	ff 75 08             	pushl  0x8(%ebp)
801058ac:	e8 c6 ff ff ff       	call   80105877 <argint>
801058b1:	83 c4 08             	add    $0x8,%esp
801058b4:	85 c0                	test   %eax,%eax
801058b6:	79 07                	jns    801058bf <argptr+0x20>
    return -1;
801058b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bd:	eb 3b                	jmp    801058fa <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801058bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058c5:	8b 00                	mov    (%eax),%eax
801058c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058ca:	39 d0                	cmp    %edx,%eax
801058cc:	76 16                	jbe    801058e4 <argptr+0x45>
801058ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d1:	89 c2                	mov    %eax,%edx
801058d3:	8b 45 10             	mov    0x10(%ebp),%eax
801058d6:	01 c2                	add    %eax,%edx
801058d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058de:	8b 00                	mov    (%eax),%eax
801058e0:	39 c2                	cmp    %eax,%edx
801058e2:	76 07                	jbe    801058eb <argptr+0x4c>
    return -1;
801058e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058e9:	eb 0f                	jmp    801058fa <argptr+0x5b>
  *pp = (char*)i;
801058eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058ee:	89 c2                	mov    %eax,%edx
801058f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f3:	89 10                	mov    %edx,(%eax)
  return 0;
801058f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058fa:	c9                   	leave  
801058fb:	c3                   	ret    

801058fc <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801058fc:	55                   	push   %ebp
801058fd:	89 e5                	mov    %esp,%ebp
801058ff:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105902:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105905:	50                   	push   %eax
80105906:	ff 75 08             	pushl  0x8(%ebp)
80105909:	e8 69 ff ff ff       	call   80105877 <argint>
8010590e:	83 c4 08             	add    $0x8,%esp
80105911:	85 c0                	test   %eax,%eax
80105913:	79 07                	jns    8010591c <argstr+0x20>
    return -1;
80105915:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591a:	eb 0f                	jmp    8010592b <argstr+0x2f>
  return fetchstr(addr, pp);
8010591c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010591f:	ff 75 0c             	pushl  0xc(%ebp)
80105922:	50                   	push   %eax
80105923:	e8 ed fe ff ff       	call   80105815 <fetchstr>
80105928:	83 c4 08             	add    $0x8,%esp
}
8010592b:	c9                   	leave  
8010592c:	c3                   	ret    

8010592d <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010592d:	55                   	push   %ebp
8010592e:	89 e5                	mov    %esp,%ebp
80105930:	53                   	push   %ebx
80105931:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105934:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010593a:	8b 40 18             	mov    0x18(%eax),%eax
8010593d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105940:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105943:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105947:	7e 30                	jle    80105979 <syscall+0x4c>
80105949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594c:	83 f8 15             	cmp    $0x15,%eax
8010594f:	77 28                	ja     80105979 <syscall+0x4c>
80105951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105954:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010595b:	85 c0                	test   %eax,%eax
8010595d:	74 1a                	je     80105979 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010595f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105965:	8b 58 18             	mov    0x18(%eax),%ebx
80105968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596b:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105972:	ff d0                	call   *%eax
80105974:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105977:	eb 34                	jmp    801059ad <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105979:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010597f:	8d 50 6c             	lea    0x6c(%eax),%edx
80105982:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105988:	8b 40 10             	mov    0x10(%eax),%eax
8010598b:	ff 75 f4             	pushl  -0xc(%ebp)
8010598e:	52                   	push   %edx
8010598f:	50                   	push   %eax
80105990:	68 97 8c 10 80       	push   $0x80108c97
80105995:	e8 2c aa ff ff       	call   801003c6 <cprintf>
8010599a:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010599d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059a3:	8b 40 18             	mov    0x18(%eax),%eax
801059a6:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801059ad:	90                   	nop
801059ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801059b1:	c9                   	leave  
801059b2:	c3                   	ret    

801059b3 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801059b3:	55                   	push   %ebp
801059b4:	89 e5                	mov    %esp,%ebp
801059b6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801059b9:	83 ec 08             	sub    $0x8,%esp
801059bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059bf:	50                   	push   %eax
801059c0:	ff 75 08             	pushl  0x8(%ebp)
801059c3:	e8 af fe ff ff       	call   80105877 <argint>
801059c8:	83 c4 10             	add    $0x10,%esp
801059cb:	85 c0                	test   %eax,%eax
801059cd:	79 07                	jns    801059d6 <argfd+0x23>
    return -1;
801059cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d4:	eb 50                	jmp    80105a26 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801059d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d9:	85 c0                	test   %eax,%eax
801059db:	78 21                	js     801059fe <argfd+0x4b>
801059dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e0:	83 f8 0f             	cmp    $0xf,%eax
801059e3:	7f 19                	jg     801059fe <argfd+0x4b>
801059e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059ee:	83 c2 08             	add    $0x8,%edx
801059f1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059fc:	75 07                	jne    80105a05 <argfd+0x52>
    return -1;
801059fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a03:	eb 21                	jmp    80105a26 <argfd+0x73>
  if(pfd)
80105a05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a09:	74 08                	je     80105a13 <argfd+0x60>
    *pfd = fd;
80105a0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a11:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a17:	74 08                	je     80105a21 <argfd+0x6e>
    *pf = f;
80105a19:	8b 45 10             	mov    0x10(%ebp),%eax
80105a1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a1f:	89 10                	mov    %edx,(%eax)
  return 0;
80105a21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a26:	c9                   	leave  
80105a27:	c3                   	ret    

80105a28 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a28:	55                   	push   %ebp
80105a29:	89 e5                	mov    %esp,%ebp
80105a2b:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105a2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105a35:	eb 30                	jmp    80105a67 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105a37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a3d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a40:	83 c2 08             	add    $0x8,%edx
80105a43:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a47:	85 c0                	test   %eax,%eax
80105a49:	75 18                	jne    80105a63 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105a4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a51:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a54:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a57:	8b 55 08             	mov    0x8(%ebp),%edx
80105a5a:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a61:	eb 0f                	jmp    80105a72 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105a63:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105a67:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105a6b:	7e ca                	jle    80105a37 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105a6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a72:	c9                   	leave  
80105a73:	c3                   	ret    

80105a74 <sys_dup>:

int
sys_dup(void)
{
80105a74:	55                   	push   %ebp
80105a75:	89 e5                	mov    %esp,%ebp
80105a77:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105a7a:	83 ec 04             	sub    $0x4,%esp
80105a7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a80:	50                   	push   %eax
80105a81:	6a 00                	push   $0x0
80105a83:	6a 00                	push   $0x0
80105a85:	e8 29 ff ff ff       	call   801059b3 <argfd>
80105a8a:	83 c4 10             	add    $0x10,%esp
80105a8d:	85 c0                	test   %eax,%eax
80105a8f:	79 07                	jns    80105a98 <sys_dup+0x24>
    return -1;
80105a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a96:	eb 31                	jmp    80105ac9 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9b:	83 ec 0c             	sub    $0xc,%esp
80105a9e:	50                   	push   %eax
80105a9f:	e8 84 ff ff ff       	call   80105a28 <fdalloc>
80105aa4:	83 c4 10             	add    $0x10,%esp
80105aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aaa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aae:	79 07                	jns    80105ab7 <sys_dup+0x43>
    return -1;
80105ab0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab5:	eb 12                	jmp    80105ac9 <sys_dup+0x55>
  filedup(f);
80105ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aba:	83 ec 0c             	sub    $0xc,%esp
80105abd:	50                   	push   %eax
80105abe:	e8 3d b5 ff ff       	call   80101000 <filedup>
80105ac3:	83 c4 10             	add    $0x10,%esp
  return fd;
80105ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105ac9:	c9                   	leave  
80105aca:	c3                   	ret    

80105acb <sys_read>:

int
sys_read(void)
{
80105acb:	55                   	push   %ebp
80105acc:	89 e5                	mov    %esp,%ebp
80105ace:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105ad1:	83 ec 04             	sub    $0x4,%esp
80105ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ad7:	50                   	push   %eax
80105ad8:	6a 00                	push   $0x0
80105ada:	6a 00                	push   $0x0
80105adc:	e8 d2 fe ff ff       	call   801059b3 <argfd>
80105ae1:	83 c4 10             	add    $0x10,%esp
80105ae4:	85 c0                	test   %eax,%eax
80105ae6:	78 2e                	js     80105b16 <sys_read+0x4b>
80105ae8:	83 ec 08             	sub    $0x8,%esp
80105aeb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aee:	50                   	push   %eax
80105aef:	6a 02                	push   $0x2
80105af1:	e8 81 fd ff ff       	call   80105877 <argint>
80105af6:	83 c4 10             	add    $0x10,%esp
80105af9:	85 c0                	test   %eax,%eax
80105afb:	78 19                	js     80105b16 <sys_read+0x4b>
80105afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b00:	83 ec 04             	sub    $0x4,%esp
80105b03:	50                   	push   %eax
80105b04:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b07:	50                   	push   %eax
80105b08:	6a 01                	push   $0x1
80105b0a:	e8 90 fd ff ff       	call   8010589f <argptr>
80105b0f:	83 c4 10             	add    $0x10,%esp
80105b12:	85 c0                	test   %eax,%eax
80105b14:	79 07                	jns    80105b1d <sys_read+0x52>
    return -1;
80105b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1b:	eb 17                	jmp    80105b34 <sys_read+0x69>
  return fileread(f, p, n);
80105b1d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b20:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b26:	83 ec 04             	sub    $0x4,%esp
80105b29:	51                   	push   %ecx
80105b2a:	52                   	push   %edx
80105b2b:	50                   	push   %eax
80105b2c:	e8 5f b6 ff ff       	call   80101190 <fileread>
80105b31:	83 c4 10             	add    $0x10,%esp
}
80105b34:	c9                   	leave  
80105b35:	c3                   	ret    

80105b36 <sys_write>:

int
sys_write(void)
{
80105b36:	55                   	push   %ebp
80105b37:	89 e5                	mov    %esp,%ebp
80105b39:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b3c:	83 ec 04             	sub    $0x4,%esp
80105b3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b42:	50                   	push   %eax
80105b43:	6a 00                	push   $0x0
80105b45:	6a 00                	push   $0x0
80105b47:	e8 67 fe ff ff       	call   801059b3 <argfd>
80105b4c:	83 c4 10             	add    $0x10,%esp
80105b4f:	85 c0                	test   %eax,%eax
80105b51:	78 2e                	js     80105b81 <sys_write+0x4b>
80105b53:	83 ec 08             	sub    $0x8,%esp
80105b56:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b59:	50                   	push   %eax
80105b5a:	6a 02                	push   $0x2
80105b5c:	e8 16 fd ff ff       	call   80105877 <argint>
80105b61:	83 c4 10             	add    $0x10,%esp
80105b64:	85 c0                	test   %eax,%eax
80105b66:	78 19                	js     80105b81 <sys_write+0x4b>
80105b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6b:	83 ec 04             	sub    $0x4,%esp
80105b6e:	50                   	push   %eax
80105b6f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b72:	50                   	push   %eax
80105b73:	6a 01                	push   $0x1
80105b75:	e8 25 fd ff ff       	call   8010589f <argptr>
80105b7a:	83 c4 10             	add    $0x10,%esp
80105b7d:	85 c0                	test   %eax,%eax
80105b7f:	79 07                	jns    80105b88 <sys_write+0x52>
    return -1;
80105b81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b86:	eb 17                	jmp    80105b9f <sys_write+0x69>
  return filewrite(f, p, n);
80105b88:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b91:	83 ec 04             	sub    $0x4,%esp
80105b94:	51                   	push   %ecx
80105b95:	52                   	push   %edx
80105b96:	50                   	push   %eax
80105b97:	e8 ac b6 ff ff       	call   80101248 <filewrite>
80105b9c:	83 c4 10             	add    $0x10,%esp
}
80105b9f:	c9                   	leave  
80105ba0:	c3                   	ret    

80105ba1 <sys_close>:

int
sys_close(void)
{
80105ba1:	55                   	push   %ebp
80105ba2:	89 e5                	mov    %esp,%ebp
80105ba4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105ba7:	83 ec 04             	sub    $0x4,%esp
80105baa:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bad:	50                   	push   %eax
80105bae:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bb1:	50                   	push   %eax
80105bb2:	6a 00                	push   $0x0
80105bb4:	e8 fa fd ff ff       	call   801059b3 <argfd>
80105bb9:	83 c4 10             	add    $0x10,%esp
80105bbc:	85 c0                	test   %eax,%eax
80105bbe:	79 07                	jns    80105bc7 <sys_close+0x26>
    return -1;
80105bc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc5:	eb 28                	jmp    80105bef <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105bc7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bcd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bd0:	83 c2 08             	add    $0x8,%edx
80105bd3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105bda:	00 
  fileclose(f);
80105bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bde:	83 ec 0c             	sub    $0xc,%esp
80105be1:	50                   	push   %eax
80105be2:	e8 6a b4 ff ff       	call   80101051 <fileclose>
80105be7:	83 c4 10             	add    $0x10,%esp
  return 0;
80105bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bef:	c9                   	leave  
80105bf0:	c3                   	ret    

80105bf1 <sys_fstat>:

int
sys_fstat(void)
{
80105bf1:	55                   	push   %ebp
80105bf2:	89 e5                	mov    %esp,%ebp
80105bf4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105bf7:	83 ec 04             	sub    $0x4,%esp
80105bfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bfd:	50                   	push   %eax
80105bfe:	6a 00                	push   $0x0
80105c00:	6a 00                	push   $0x0
80105c02:	e8 ac fd ff ff       	call   801059b3 <argfd>
80105c07:	83 c4 10             	add    $0x10,%esp
80105c0a:	85 c0                	test   %eax,%eax
80105c0c:	78 17                	js     80105c25 <sys_fstat+0x34>
80105c0e:	83 ec 04             	sub    $0x4,%esp
80105c11:	6a 14                	push   $0x14
80105c13:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c16:	50                   	push   %eax
80105c17:	6a 01                	push   $0x1
80105c19:	e8 81 fc ff ff       	call   8010589f <argptr>
80105c1e:	83 c4 10             	add    $0x10,%esp
80105c21:	85 c0                	test   %eax,%eax
80105c23:	79 07                	jns    80105c2c <sys_fstat+0x3b>
    return -1;
80105c25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c2a:	eb 13                	jmp    80105c3f <sys_fstat+0x4e>
  return filestat(f, st);
80105c2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c32:	83 ec 08             	sub    $0x8,%esp
80105c35:	52                   	push   %edx
80105c36:	50                   	push   %eax
80105c37:	e8 fd b4 ff ff       	call   80101139 <filestat>
80105c3c:	83 c4 10             	add    $0x10,%esp
}
80105c3f:	c9                   	leave  
80105c40:	c3                   	ret    

80105c41 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c41:	55                   	push   %ebp
80105c42:	89 e5                	mov    %esp,%ebp
80105c44:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c47:	83 ec 08             	sub    $0x8,%esp
80105c4a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105c4d:	50                   	push   %eax
80105c4e:	6a 00                	push   $0x0
80105c50:	e8 a7 fc ff ff       	call   801058fc <argstr>
80105c55:	83 c4 10             	add    $0x10,%esp
80105c58:	85 c0                	test   %eax,%eax
80105c5a:	78 15                	js     80105c71 <sys_link+0x30>
80105c5c:	83 ec 08             	sub    $0x8,%esp
80105c5f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c62:	50                   	push   %eax
80105c63:	6a 01                	push   $0x1
80105c65:	e8 92 fc ff ff       	call   801058fc <argstr>
80105c6a:	83 c4 10             	add    $0x10,%esp
80105c6d:	85 c0                	test   %eax,%eax
80105c6f:	79 0a                	jns    80105c7b <sys_link+0x3a>
    return -1;
80105c71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c76:	e9 68 01 00 00       	jmp    80105de3 <sys_link+0x1a2>

  begin_op();
80105c7b:	e8 cd d8 ff ff       	call   8010354d <begin_op>
  if((ip = namei(old)) == 0){
80105c80:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c83:	83 ec 0c             	sub    $0xc,%esp
80105c86:	50                   	push   %eax
80105c87:	e8 9c c8 ff ff       	call   80102528 <namei>
80105c8c:	83 c4 10             	add    $0x10,%esp
80105c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c96:	75 0f                	jne    80105ca7 <sys_link+0x66>
    end_op();
80105c98:	e8 3c d9 ff ff       	call   801035d9 <end_op>
    return -1;
80105c9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca2:	e9 3c 01 00 00       	jmp    80105de3 <sys_link+0x1a2>
  }

  ilock(ip);
80105ca7:	83 ec 0c             	sub    $0xc,%esp
80105caa:	ff 75 f4             	pushl  -0xc(%ebp)
80105cad:	e8 b8 bc ff ff       	call   8010196a <ilock>
80105cb2:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cbc:	66 83 f8 01          	cmp    $0x1,%ax
80105cc0:	75 1d                	jne    80105cdf <sys_link+0x9e>
    iunlockput(ip);
80105cc2:	83 ec 0c             	sub    $0xc,%esp
80105cc5:	ff 75 f4             	pushl  -0xc(%ebp)
80105cc8:	e8 5d bf ff ff       	call   80101c2a <iunlockput>
80105ccd:	83 c4 10             	add    $0x10,%esp
    end_op();
80105cd0:	e8 04 d9 ff ff       	call   801035d9 <end_op>
    return -1;
80105cd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cda:	e9 04 01 00 00       	jmp    80105de3 <sys_link+0x1a2>
  }

  ip->nlink++;
80105cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ce6:	83 c0 01             	add    $0x1,%eax
80105ce9:	89 c2                	mov    %eax,%edx
80105ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cee:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105cf2:	83 ec 0c             	sub    $0xc,%esp
80105cf5:	ff 75 f4             	pushl  -0xc(%ebp)
80105cf8:	e8 93 ba ff ff       	call   80101790 <iupdate>
80105cfd:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105d00:	83 ec 0c             	sub    $0xc,%esp
80105d03:	ff 75 f4             	pushl  -0xc(%ebp)
80105d06:	e8 bd bd ff ff       	call   80101ac8 <iunlock>
80105d0b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105d0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d11:	83 ec 08             	sub    $0x8,%esp
80105d14:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d17:	52                   	push   %edx
80105d18:	50                   	push   %eax
80105d19:	e8 26 c8 ff ff       	call   80102544 <nameiparent>
80105d1e:	83 c4 10             	add    $0x10,%esp
80105d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d28:	74 71                	je     80105d9b <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105d2a:	83 ec 0c             	sub    $0xc,%esp
80105d2d:	ff 75 f0             	pushl  -0x10(%ebp)
80105d30:	e8 35 bc ff ff       	call   8010196a <ilock>
80105d35:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d3b:	8b 10                	mov    (%eax),%edx
80105d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d40:	8b 00                	mov    (%eax),%eax
80105d42:	39 c2                	cmp    %eax,%edx
80105d44:	75 1d                	jne    80105d63 <sys_link+0x122>
80105d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d49:	8b 40 04             	mov    0x4(%eax),%eax
80105d4c:	83 ec 04             	sub    $0x4,%esp
80105d4f:	50                   	push   %eax
80105d50:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d53:	50                   	push   %eax
80105d54:	ff 75 f0             	pushl  -0x10(%ebp)
80105d57:	e8 30 c5 ff ff       	call   8010228c <dirlink>
80105d5c:	83 c4 10             	add    $0x10,%esp
80105d5f:	85 c0                	test   %eax,%eax
80105d61:	79 10                	jns    80105d73 <sys_link+0x132>
    iunlockput(dp);
80105d63:	83 ec 0c             	sub    $0xc,%esp
80105d66:	ff 75 f0             	pushl  -0x10(%ebp)
80105d69:	e8 bc be ff ff       	call   80101c2a <iunlockput>
80105d6e:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d71:	eb 29                	jmp    80105d9c <sys_link+0x15b>
  }
  iunlockput(dp);
80105d73:	83 ec 0c             	sub    $0xc,%esp
80105d76:	ff 75 f0             	pushl  -0x10(%ebp)
80105d79:	e8 ac be ff ff       	call   80101c2a <iunlockput>
80105d7e:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105d81:	83 ec 0c             	sub    $0xc,%esp
80105d84:	ff 75 f4             	pushl  -0xc(%ebp)
80105d87:	e8 ae bd ff ff       	call   80101b3a <iput>
80105d8c:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d8f:	e8 45 d8 ff ff       	call   801035d9 <end_op>

  return 0;
80105d94:	b8 00 00 00 00       	mov    $0x0,%eax
80105d99:	eb 48                	jmp    80105de3 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105d9b:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105d9c:	83 ec 0c             	sub    $0xc,%esp
80105d9f:	ff 75 f4             	pushl  -0xc(%ebp)
80105da2:	e8 c3 bb ff ff       	call   8010196a <ilock>
80105da7:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dad:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105db1:	83 e8 01             	sub    $0x1,%eax
80105db4:	89 c2                	mov    %eax,%edx
80105db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105dbd:	83 ec 0c             	sub    $0xc,%esp
80105dc0:	ff 75 f4             	pushl  -0xc(%ebp)
80105dc3:	e8 c8 b9 ff ff       	call   80101790 <iupdate>
80105dc8:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105dcb:	83 ec 0c             	sub    $0xc,%esp
80105dce:	ff 75 f4             	pushl  -0xc(%ebp)
80105dd1:	e8 54 be ff ff       	call   80101c2a <iunlockput>
80105dd6:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dd9:	e8 fb d7 ff ff       	call   801035d9 <end_op>
  return -1;
80105dde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105de3:	c9                   	leave  
80105de4:	c3                   	ret    

80105de5 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105de5:	55                   	push   %ebp
80105de6:	89 e5                	mov    %esp,%ebp
80105de8:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105deb:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105df2:	eb 40                	jmp    80105e34 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df7:	6a 10                	push   $0x10
80105df9:	50                   	push   %eax
80105dfa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105dfd:	50                   	push   %eax
80105dfe:	ff 75 08             	pushl  0x8(%ebp)
80105e01:	e8 d2 c0 ff ff       	call   80101ed8 <readi>
80105e06:	83 c4 10             	add    $0x10,%esp
80105e09:	83 f8 10             	cmp    $0x10,%eax
80105e0c:	74 0d                	je     80105e1b <isdirempty+0x36>
      panic("isdirempty: readi");
80105e0e:	83 ec 0c             	sub    $0xc,%esp
80105e11:	68 b3 8c 10 80       	push   $0x80108cb3
80105e16:	e8 4b a7 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105e1b:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e1f:	66 85 c0             	test   %ax,%ax
80105e22:	74 07                	je     80105e2b <isdirempty+0x46>
      return 0;
80105e24:	b8 00 00 00 00       	mov    $0x0,%eax
80105e29:	eb 1b                	jmp    80105e46 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2e:	83 c0 10             	add    $0x10,%eax
80105e31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e34:	8b 45 08             	mov    0x8(%ebp),%eax
80105e37:	8b 50 18             	mov    0x18(%eax),%edx
80105e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3d:	39 c2                	cmp    %eax,%edx
80105e3f:	77 b3                	ja     80105df4 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105e41:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e46:	c9                   	leave  
80105e47:	c3                   	ret    

80105e48 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e48:	55                   	push   %ebp
80105e49:	89 e5                	mov    %esp,%ebp
80105e4b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e4e:	83 ec 08             	sub    $0x8,%esp
80105e51:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105e54:	50                   	push   %eax
80105e55:	6a 00                	push   $0x0
80105e57:	e8 a0 fa ff ff       	call   801058fc <argstr>
80105e5c:	83 c4 10             	add    $0x10,%esp
80105e5f:	85 c0                	test   %eax,%eax
80105e61:	79 0a                	jns    80105e6d <sys_unlink+0x25>
    return -1;
80105e63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e68:	e9 bc 01 00 00       	jmp    80106029 <sys_unlink+0x1e1>

  begin_op();
80105e6d:	e8 db d6 ff ff       	call   8010354d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105e72:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105e75:	83 ec 08             	sub    $0x8,%esp
80105e78:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105e7b:	52                   	push   %edx
80105e7c:	50                   	push   %eax
80105e7d:	e8 c2 c6 ff ff       	call   80102544 <nameiparent>
80105e82:	83 c4 10             	add    $0x10,%esp
80105e85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e8c:	75 0f                	jne    80105e9d <sys_unlink+0x55>
    end_op();
80105e8e:	e8 46 d7 ff ff       	call   801035d9 <end_op>
    return -1;
80105e93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e98:	e9 8c 01 00 00       	jmp    80106029 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105e9d:	83 ec 0c             	sub    $0xc,%esp
80105ea0:	ff 75 f4             	pushl  -0xc(%ebp)
80105ea3:	e8 c2 ba ff ff       	call   8010196a <ilock>
80105ea8:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105eab:	83 ec 08             	sub    $0x8,%esp
80105eae:	68 c5 8c 10 80       	push   $0x80108cc5
80105eb3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105eb6:	50                   	push   %eax
80105eb7:	e8 fb c2 ff ff       	call   801021b7 <namecmp>
80105ebc:	83 c4 10             	add    $0x10,%esp
80105ebf:	85 c0                	test   %eax,%eax
80105ec1:	0f 84 4a 01 00 00    	je     80106011 <sys_unlink+0x1c9>
80105ec7:	83 ec 08             	sub    $0x8,%esp
80105eca:	68 c7 8c 10 80       	push   $0x80108cc7
80105ecf:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ed2:	50                   	push   %eax
80105ed3:	e8 df c2 ff ff       	call   801021b7 <namecmp>
80105ed8:	83 c4 10             	add    $0x10,%esp
80105edb:	85 c0                	test   %eax,%eax
80105edd:	0f 84 2e 01 00 00    	je     80106011 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ee3:	83 ec 04             	sub    $0x4,%esp
80105ee6:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ee9:	50                   	push   %eax
80105eea:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105eed:	50                   	push   %eax
80105eee:	ff 75 f4             	pushl  -0xc(%ebp)
80105ef1:	e8 dc c2 ff ff       	call   801021d2 <dirlookup>
80105ef6:	83 c4 10             	add    $0x10,%esp
80105ef9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105efc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f00:	0f 84 0a 01 00 00    	je     80106010 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105f06:	83 ec 0c             	sub    $0xc,%esp
80105f09:	ff 75 f0             	pushl  -0x10(%ebp)
80105f0c:	e8 59 ba ff ff       	call   8010196a <ilock>
80105f11:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f17:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f1b:	66 85 c0             	test   %ax,%ax
80105f1e:	7f 0d                	jg     80105f2d <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105f20:	83 ec 0c             	sub    $0xc,%esp
80105f23:	68 ca 8c 10 80       	push   $0x80108cca
80105f28:	e8 39 a6 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f30:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f34:	66 83 f8 01          	cmp    $0x1,%ax
80105f38:	75 25                	jne    80105f5f <sys_unlink+0x117>
80105f3a:	83 ec 0c             	sub    $0xc,%esp
80105f3d:	ff 75 f0             	pushl  -0x10(%ebp)
80105f40:	e8 a0 fe ff ff       	call   80105de5 <isdirempty>
80105f45:	83 c4 10             	add    $0x10,%esp
80105f48:	85 c0                	test   %eax,%eax
80105f4a:	75 13                	jne    80105f5f <sys_unlink+0x117>
    iunlockput(ip);
80105f4c:	83 ec 0c             	sub    $0xc,%esp
80105f4f:	ff 75 f0             	pushl  -0x10(%ebp)
80105f52:	e8 d3 bc ff ff       	call   80101c2a <iunlockput>
80105f57:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105f5a:	e9 b2 00 00 00       	jmp    80106011 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105f5f:	83 ec 04             	sub    $0x4,%esp
80105f62:	6a 10                	push   $0x10
80105f64:	6a 00                	push   $0x0
80105f66:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f69:	50                   	push   %eax
80105f6a:	e8 e3 f5 ff ff       	call   80105552 <memset>
80105f6f:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f72:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105f75:	6a 10                	push   $0x10
80105f77:	50                   	push   %eax
80105f78:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f7b:	50                   	push   %eax
80105f7c:	ff 75 f4             	pushl  -0xc(%ebp)
80105f7f:	e8 ab c0 ff ff       	call   8010202f <writei>
80105f84:	83 c4 10             	add    $0x10,%esp
80105f87:	83 f8 10             	cmp    $0x10,%eax
80105f8a:	74 0d                	je     80105f99 <sys_unlink+0x151>
    panic("unlink: writei");
80105f8c:	83 ec 0c             	sub    $0xc,%esp
80105f8f:	68 dc 8c 10 80       	push   $0x80108cdc
80105f94:	e8 cd a5 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80105f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fa0:	66 83 f8 01          	cmp    $0x1,%ax
80105fa4:	75 21                	jne    80105fc7 <sys_unlink+0x17f>
    dp->nlink--;
80105fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105fad:	83 e8 01             	sub    $0x1,%eax
80105fb0:	89 c2                	mov    %eax,%edx
80105fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb5:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105fb9:	83 ec 0c             	sub    $0xc,%esp
80105fbc:	ff 75 f4             	pushl  -0xc(%ebp)
80105fbf:	e8 cc b7 ff ff       	call   80101790 <iupdate>
80105fc4:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105fc7:	83 ec 0c             	sub    $0xc,%esp
80105fca:	ff 75 f4             	pushl  -0xc(%ebp)
80105fcd:	e8 58 bc ff ff       	call   80101c2a <iunlockput>
80105fd2:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105fdc:	83 e8 01             	sub    $0x1,%eax
80105fdf:	89 c2                	mov    %eax,%edx
80105fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe4:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105fe8:	83 ec 0c             	sub    $0xc,%esp
80105feb:	ff 75 f0             	pushl  -0x10(%ebp)
80105fee:	e8 9d b7 ff ff       	call   80101790 <iupdate>
80105ff3:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ff6:	83 ec 0c             	sub    $0xc,%esp
80105ff9:	ff 75 f0             	pushl  -0x10(%ebp)
80105ffc:	e8 29 bc ff ff       	call   80101c2a <iunlockput>
80106001:	83 c4 10             	add    $0x10,%esp

  end_op();
80106004:	e8 d0 d5 ff ff       	call   801035d9 <end_op>

  return 0;
80106009:	b8 00 00 00 00       	mov    $0x0,%eax
8010600e:	eb 19                	jmp    80106029 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106010:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106011:	83 ec 0c             	sub    $0xc,%esp
80106014:	ff 75 f4             	pushl  -0xc(%ebp)
80106017:	e8 0e bc ff ff       	call   80101c2a <iunlockput>
8010601c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010601f:	e8 b5 d5 ff ff       	call   801035d9 <end_op>
  return -1;
80106024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106029:	c9                   	leave  
8010602a:	c3                   	ret    

8010602b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010602b:	55                   	push   %ebp
8010602c:	89 e5                	mov    %esp,%ebp
8010602e:	83 ec 38             	sub    $0x38,%esp
80106031:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106034:	8b 55 10             	mov    0x10(%ebp),%edx
80106037:	8b 45 14             	mov    0x14(%ebp),%eax
8010603a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010603e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106042:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106046:	83 ec 08             	sub    $0x8,%esp
80106049:	8d 45 de             	lea    -0x22(%ebp),%eax
8010604c:	50                   	push   %eax
8010604d:	ff 75 08             	pushl  0x8(%ebp)
80106050:	e8 ef c4 ff ff       	call   80102544 <nameiparent>
80106055:	83 c4 10             	add    $0x10,%esp
80106058:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010605b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010605f:	75 0a                	jne    8010606b <create+0x40>
    return 0;
80106061:	b8 00 00 00 00       	mov    $0x0,%eax
80106066:	e9 90 01 00 00       	jmp    801061fb <create+0x1d0>
  ilock(dp);
8010606b:	83 ec 0c             	sub    $0xc,%esp
8010606e:	ff 75 f4             	pushl  -0xc(%ebp)
80106071:	e8 f4 b8 ff ff       	call   8010196a <ilock>
80106076:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106079:	83 ec 04             	sub    $0x4,%esp
8010607c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010607f:	50                   	push   %eax
80106080:	8d 45 de             	lea    -0x22(%ebp),%eax
80106083:	50                   	push   %eax
80106084:	ff 75 f4             	pushl  -0xc(%ebp)
80106087:	e8 46 c1 ff ff       	call   801021d2 <dirlookup>
8010608c:	83 c4 10             	add    $0x10,%esp
8010608f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106092:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106096:	74 50                	je     801060e8 <create+0xbd>
    iunlockput(dp);
80106098:	83 ec 0c             	sub    $0xc,%esp
8010609b:	ff 75 f4             	pushl  -0xc(%ebp)
8010609e:	e8 87 bb ff ff       	call   80101c2a <iunlockput>
801060a3:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801060a6:	83 ec 0c             	sub    $0xc,%esp
801060a9:	ff 75 f0             	pushl  -0x10(%ebp)
801060ac:	e8 b9 b8 ff ff       	call   8010196a <ilock>
801060b1:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801060b4:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801060b9:	75 15                	jne    801060d0 <create+0xa5>
801060bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060be:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060c2:	66 83 f8 02          	cmp    $0x2,%ax
801060c6:	75 08                	jne    801060d0 <create+0xa5>
      return ip;
801060c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cb:	e9 2b 01 00 00       	jmp    801061fb <create+0x1d0>
    iunlockput(ip);
801060d0:	83 ec 0c             	sub    $0xc,%esp
801060d3:	ff 75 f0             	pushl  -0x10(%ebp)
801060d6:	e8 4f bb ff ff       	call   80101c2a <iunlockput>
801060db:	83 c4 10             	add    $0x10,%esp
    return 0;
801060de:	b8 00 00 00 00       	mov    $0x0,%eax
801060e3:	e9 13 01 00 00       	jmp    801061fb <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801060e8:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801060ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ef:	8b 00                	mov    (%eax),%eax
801060f1:	83 ec 08             	sub    $0x8,%esp
801060f4:	52                   	push   %edx
801060f5:	50                   	push   %eax
801060f6:	e8 be b5 ff ff       	call   801016b9 <ialloc>
801060fb:	83 c4 10             	add    $0x10,%esp
801060fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106101:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106105:	75 0d                	jne    80106114 <create+0xe9>
    panic("create: ialloc");
80106107:	83 ec 0c             	sub    $0xc,%esp
8010610a:	68 eb 8c 10 80       	push   $0x80108ceb
8010610f:	e8 52 a4 ff ff       	call   80100566 <panic>

  ilock(ip);
80106114:	83 ec 0c             	sub    $0xc,%esp
80106117:	ff 75 f0             	pushl  -0x10(%ebp)
8010611a:	e8 4b b8 ff ff       	call   8010196a <ilock>
8010611f:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106122:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106125:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106129:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010612d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106130:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106134:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106138:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613b:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106141:	83 ec 0c             	sub    $0xc,%esp
80106144:	ff 75 f0             	pushl  -0x10(%ebp)
80106147:	e8 44 b6 ff ff       	call   80101790 <iupdate>
8010614c:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010614f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106154:	75 6a                	jne    801061c0 <create+0x195>
    dp->nlink++;  // for ".."
80106156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106159:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010615d:	83 c0 01             	add    $0x1,%eax
80106160:	89 c2                	mov    %eax,%edx
80106162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106165:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106169:	83 ec 0c             	sub    $0xc,%esp
8010616c:	ff 75 f4             	pushl  -0xc(%ebp)
8010616f:	e8 1c b6 ff ff       	call   80101790 <iupdate>
80106174:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617a:	8b 40 04             	mov    0x4(%eax),%eax
8010617d:	83 ec 04             	sub    $0x4,%esp
80106180:	50                   	push   %eax
80106181:	68 c5 8c 10 80       	push   $0x80108cc5
80106186:	ff 75 f0             	pushl  -0x10(%ebp)
80106189:	e8 fe c0 ff ff       	call   8010228c <dirlink>
8010618e:	83 c4 10             	add    $0x10,%esp
80106191:	85 c0                	test   %eax,%eax
80106193:	78 1e                	js     801061b3 <create+0x188>
80106195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106198:	8b 40 04             	mov    0x4(%eax),%eax
8010619b:	83 ec 04             	sub    $0x4,%esp
8010619e:	50                   	push   %eax
8010619f:	68 c7 8c 10 80       	push   $0x80108cc7
801061a4:	ff 75 f0             	pushl  -0x10(%ebp)
801061a7:	e8 e0 c0 ff ff       	call   8010228c <dirlink>
801061ac:	83 c4 10             	add    $0x10,%esp
801061af:	85 c0                	test   %eax,%eax
801061b1:	79 0d                	jns    801061c0 <create+0x195>
      panic("create dots");
801061b3:	83 ec 0c             	sub    $0xc,%esp
801061b6:	68 fa 8c 10 80       	push   $0x80108cfa
801061bb:	e8 a6 a3 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801061c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c3:	8b 40 04             	mov    0x4(%eax),%eax
801061c6:	83 ec 04             	sub    $0x4,%esp
801061c9:	50                   	push   %eax
801061ca:	8d 45 de             	lea    -0x22(%ebp),%eax
801061cd:	50                   	push   %eax
801061ce:	ff 75 f4             	pushl  -0xc(%ebp)
801061d1:	e8 b6 c0 ff ff       	call   8010228c <dirlink>
801061d6:	83 c4 10             	add    $0x10,%esp
801061d9:	85 c0                	test   %eax,%eax
801061db:	79 0d                	jns    801061ea <create+0x1bf>
    panic("create: dirlink");
801061dd:	83 ec 0c             	sub    $0xc,%esp
801061e0:	68 06 8d 10 80       	push   $0x80108d06
801061e5:	e8 7c a3 ff ff       	call   80100566 <panic>

  iunlockput(dp);
801061ea:	83 ec 0c             	sub    $0xc,%esp
801061ed:	ff 75 f4             	pushl  -0xc(%ebp)
801061f0:	e8 35 ba ff ff       	call   80101c2a <iunlockput>
801061f5:	83 c4 10             	add    $0x10,%esp

  return ip;
801061f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801061fb:	c9                   	leave  
801061fc:	c3                   	ret    

801061fd <sys_open>:

int
sys_open(void)
{
801061fd:	55                   	push   %ebp
801061fe:	89 e5                	mov    %esp,%ebp
80106200:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106203:	83 ec 08             	sub    $0x8,%esp
80106206:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106209:	50                   	push   %eax
8010620a:	6a 00                	push   $0x0
8010620c:	e8 eb f6 ff ff       	call   801058fc <argstr>
80106211:	83 c4 10             	add    $0x10,%esp
80106214:	85 c0                	test   %eax,%eax
80106216:	78 15                	js     8010622d <sys_open+0x30>
80106218:	83 ec 08             	sub    $0x8,%esp
8010621b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010621e:	50                   	push   %eax
8010621f:	6a 01                	push   $0x1
80106221:	e8 51 f6 ff ff       	call   80105877 <argint>
80106226:	83 c4 10             	add    $0x10,%esp
80106229:	85 c0                	test   %eax,%eax
8010622b:	79 0a                	jns    80106237 <sys_open+0x3a>
    return -1;
8010622d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106232:	e9 61 01 00 00       	jmp    80106398 <sys_open+0x19b>

  begin_op();
80106237:	e8 11 d3 ff ff       	call   8010354d <begin_op>

  if(omode & O_CREATE){
8010623c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010623f:	25 00 02 00 00       	and    $0x200,%eax
80106244:	85 c0                	test   %eax,%eax
80106246:	74 2a                	je     80106272 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106248:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624b:	6a 00                	push   $0x0
8010624d:	6a 00                	push   $0x0
8010624f:	6a 02                	push   $0x2
80106251:	50                   	push   %eax
80106252:	e8 d4 fd ff ff       	call   8010602b <create>
80106257:	83 c4 10             	add    $0x10,%esp
8010625a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010625d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106261:	75 75                	jne    801062d8 <sys_open+0xdb>
      end_op();
80106263:	e8 71 d3 ff ff       	call   801035d9 <end_op>
      return -1;
80106268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010626d:	e9 26 01 00 00       	jmp    80106398 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106272:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106275:	83 ec 0c             	sub    $0xc,%esp
80106278:	50                   	push   %eax
80106279:	e8 aa c2 ff ff       	call   80102528 <namei>
8010627e:	83 c4 10             	add    $0x10,%esp
80106281:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106284:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106288:	75 0f                	jne    80106299 <sys_open+0x9c>
      end_op();
8010628a:	e8 4a d3 ff ff       	call   801035d9 <end_op>
      return -1;
8010628f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106294:	e9 ff 00 00 00       	jmp    80106398 <sys_open+0x19b>
    }
    ilock(ip);
80106299:	83 ec 0c             	sub    $0xc,%esp
8010629c:	ff 75 f4             	pushl  -0xc(%ebp)
8010629f:	e8 c6 b6 ff ff       	call   8010196a <ilock>
801062a4:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801062a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062aa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062ae:	66 83 f8 01          	cmp    $0x1,%ax
801062b2:	75 24                	jne    801062d8 <sys_open+0xdb>
801062b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062b7:	85 c0                	test   %eax,%eax
801062b9:	74 1d                	je     801062d8 <sys_open+0xdb>
      iunlockput(ip);
801062bb:	83 ec 0c             	sub    $0xc,%esp
801062be:	ff 75 f4             	pushl  -0xc(%ebp)
801062c1:	e8 64 b9 ff ff       	call   80101c2a <iunlockput>
801062c6:	83 c4 10             	add    $0x10,%esp
      end_op();
801062c9:	e8 0b d3 ff ff       	call   801035d9 <end_op>
      return -1;
801062ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d3:	e9 c0 00 00 00       	jmp    80106398 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801062d8:	e8 b6 ac ff ff       	call   80100f93 <filealloc>
801062dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062e4:	74 17                	je     801062fd <sys_open+0x100>
801062e6:	83 ec 0c             	sub    $0xc,%esp
801062e9:	ff 75 f0             	pushl  -0x10(%ebp)
801062ec:	e8 37 f7 ff ff       	call   80105a28 <fdalloc>
801062f1:	83 c4 10             	add    $0x10,%esp
801062f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801062f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801062fb:	79 2e                	jns    8010632b <sys_open+0x12e>
    if(f)
801062fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106301:	74 0e                	je     80106311 <sys_open+0x114>
      fileclose(f);
80106303:	83 ec 0c             	sub    $0xc,%esp
80106306:	ff 75 f0             	pushl  -0x10(%ebp)
80106309:	e8 43 ad ff ff       	call   80101051 <fileclose>
8010630e:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106311:	83 ec 0c             	sub    $0xc,%esp
80106314:	ff 75 f4             	pushl  -0xc(%ebp)
80106317:	e8 0e b9 ff ff       	call   80101c2a <iunlockput>
8010631c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010631f:	e8 b5 d2 ff ff       	call   801035d9 <end_op>
    return -1;
80106324:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106329:	eb 6d                	jmp    80106398 <sys_open+0x19b>
  }
  iunlock(ip);
8010632b:	83 ec 0c             	sub    $0xc,%esp
8010632e:	ff 75 f4             	pushl  -0xc(%ebp)
80106331:	e8 92 b7 ff ff       	call   80101ac8 <iunlock>
80106336:	83 c4 10             	add    $0x10,%esp
  end_op();
80106339:	e8 9b d2 ff ff       	call   801035d9 <end_op>

  f->type = FD_INODE;
8010633e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106341:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106347:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010634d:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106353:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010635a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010635d:	83 e0 01             	and    $0x1,%eax
80106360:	85 c0                	test   %eax,%eax
80106362:	0f 94 c0             	sete   %al
80106365:	89 c2                	mov    %eax,%edx
80106367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010636a:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010636d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106370:	83 e0 01             	and    $0x1,%eax
80106373:	85 c0                	test   %eax,%eax
80106375:	75 0a                	jne    80106381 <sys_open+0x184>
80106377:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010637a:	83 e0 02             	and    $0x2,%eax
8010637d:	85 c0                	test   %eax,%eax
8010637f:	74 07                	je     80106388 <sys_open+0x18b>
80106381:	b8 01 00 00 00       	mov    $0x1,%eax
80106386:	eb 05                	jmp    8010638d <sys_open+0x190>
80106388:	b8 00 00 00 00       	mov    $0x0,%eax
8010638d:	89 c2                	mov    %eax,%edx
8010638f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106392:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106395:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106398:	c9                   	leave  
80106399:	c3                   	ret    

8010639a <sys_mkdir>:

int
sys_mkdir(void)
{
8010639a:	55                   	push   %ebp
8010639b:	89 e5                	mov    %esp,%ebp
8010639d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063a0:	e8 a8 d1 ff ff       	call   8010354d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801063a5:	83 ec 08             	sub    $0x8,%esp
801063a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ab:	50                   	push   %eax
801063ac:	6a 00                	push   $0x0
801063ae:	e8 49 f5 ff ff       	call   801058fc <argstr>
801063b3:	83 c4 10             	add    $0x10,%esp
801063b6:	85 c0                	test   %eax,%eax
801063b8:	78 1b                	js     801063d5 <sys_mkdir+0x3b>
801063ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063bd:	6a 00                	push   $0x0
801063bf:	6a 00                	push   $0x0
801063c1:	6a 01                	push   $0x1
801063c3:	50                   	push   %eax
801063c4:	e8 62 fc ff ff       	call   8010602b <create>
801063c9:	83 c4 10             	add    $0x10,%esp
801063cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063d3:	75 0c                	jne    801063e1 <sys_mkdir+0x47>
    end_op();
801063d5:	e8 ff d1 ff ff       	call   801035d9 <end_op>
    return -1;
801063da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063df:	eb 18                	jmp    801063f9 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801063e1:	83 ec 0c             	sub    $0xc,%esp
801063e4:	ff 75 f4             	pushl  -0xc(%ebp)
801063e7:	e8 3e b8 ff ff       	call   80101c2a <iunlockput>
801063ec:	83 c4 10             	add    $0x10,%esp
  end_op();
801063ef:	e8 e5 d1 ff ff       	call   801035d9 <end_op>
  return 0;
801063f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063f9:	c9                   	leave  
801063fa:	c3                   	ret    

801063fb <sys_mknod>:

int
sys_mknod(void)
{
801063fb:	55                   	push   %ebp
801063fc:	89 e5                	mov    %esp,%ebp
801063fe:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106401:	e8 47 d1 ff ff       	call   8010354d <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106406:	83 ec 08             	sub    $0x8,%esp
80106409:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010640c:	50                   	push   %eax
8010640d:	6a 00                	push   $0x0
8010640f:	e8 e8 f4 ff ff       	call   801058fc <argstr>
80106414:	83 c4 10             	add    $0x10,%esp
80106417:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010641a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010641e:	78 4f                	js     8010646f <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106420:	83 ec 08             	sub    $0x8,%esp
80106423:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106426:	50                   	push   %eax
80106427:	6a 01                	push   $0x1
80106429:	e8 49 f4 ff ff       	call   80105877 <argint>
8010642e:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106431:	85 c0                	test   %eax,%eax
80106433:	78 3a                	js     8010646f <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106435:	83 ec 08             	sub    $0x8,%esp
80106438:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010643b:	50                   	push   %eax
8010643c:	6a 02                	push   $0x2
8010643e:	e8 34 f4 ff ff       	call   80105877 <argint>
80106443:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106446:	85 c0                	test   %eax,%eax
80106448:	78 25                	js     8010646f <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010644a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010644d:	0f bf c8             	movswl %ax,%ecx
80106450:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106453:	0f bf d0             	movswl %ax,%edx
80106456:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106459:	51                   	push   %ecx
8010645a:	52                   	push   %edx
8010645b:	6a 03                	push   $0x3
8010645d:	50                   	push   %eax
8010645e:	e8 c8 fb ff ff       	call   8010602b <create>
80106463:	83 c4 10             	add    $0x10,%esp
80106466:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106469:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010646d:	75 0c                	jne    8010647b <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010646f:	e8 65 d1 ff ff       	call   801035d9 <end_op>
    return -1;
80106474:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106479:	eb 18                	jmp    80106493 <sys_mknod+0x98>
  }
  iunlockput(ip);
8010647b:	83 ec 0c             	sub    $0xc,%esp
8010647e:	ff 75 f0             	pushl  -0x10(%ebp)
80106481:	e8 a4 b7 ff ff       	call   80101c2a <iunlockput>
80106486:	83 c4 10             	add    $0x10,%esp
  end_op();
80106489:	e8 4b d1 ff ff       	call   801035d9 <end_op>
  return 0;
8010648e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106493:	c9                   	leave  
80106494:	c3                   	ret    

80106495 <sys_chdir>:

int
sys_chdir(void)
{
80106495:	55                   	push   %ebp
80106496:	89 e5                	mov    %esp,%ebp
80106498:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010649b:	e8 ad d0 ff ff       	call   8010354d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801064a0:	83 ec 08             	sub    $0x8,%esp
801064a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064a6:	50                   	push   %eax
801064a7:	6a 00                	push   $0x0
801064a9:	e8 4e f4 ff ff       	call   801058fc <argstr>
801064ae:	83 c4 10             	add    $0x10,%esp
801064b1:	85 c0                	test   %eax,%eax
801064b3:	78 18                	js     801064cd <sys_chdir+0x38>
801064b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b8:	83 ec 0c             	sub    $0xc,%esp
801064bb:	50                   	push   %eax
801064bc:	e8 67 c0 ff ff       	call   80102528 <namei>
801064c1:	83 c4 10             	add    $0x10,%esp
801064c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064cb:	75 0c                	jne    801064d9 <sys_chdir+0x44>
    end_op();
801064cd:	e8 07 d1 ff ff       	call   801035d9 <end_op>
    return -1;
801064d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d7:	eb 6e                	jmp    80106547 <sys_chdir+0xb2>
  }
  ilock(ip);
801064d9:	83 ec 0c             	sub    $0xc,%esp
801064dc:	ff 75 f4             	pushl  -0xc(%ebp)
801064df:	e8 86 b4 ff ff       	call   8010196a <ilock>
801064e4:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ea:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801064ee:	66 83 f8 01          	cmp    $0x1,%ax
801064f2:	74 1a                	je     8010650e <sys_chdir+0x79>
    iunlockput(ip);
801064f4:	83 ec 0c             	sub    $0xc,%esp
801064f7:	ff 75 f4             	pushl  -0xc(%ebp)
801064fa:	e8 2b b7 ff ff       	call   80101c2a <iunlockput>
801064ff:	83 c4 10             	add    $0x10,%esp
    end_op();
80106502:	e8 d2 d0 ff ff       	call   801035d9 <end_op>
    return -1;
80106507:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650c:	eb 39                	jmp    80106547 <sys_chdir+0xb2>
  }
  iunlock(ip);
8010650e:	83 ec 0c             	sub    $0xc,%esp
80106511:	ff 75 f4             	pushl  -0xc(%ebp)
80106514:	e8 af b5 ff ff       	call   80101ac8 <iunlock>
80106519:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
8010651c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106522:	8b 40 68             	mov    0x68(%eax),%eax
80106525:	83 ec 0c             	sub    $0xc,%esp
80106528:	50                   	push   %eax
80106529:	e8 0c b6 ff ff       	call   80101b3a <iput>
8010652e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106531:	e8 a3 d0 ff ff       	call   801035d9 <end_op>
  proc->cwd = ip;
80106536:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010653c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010653f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106542:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106547:	c9                   	leave  
80106548:	c3                   	ret    

80106549 <sys_exec>:

int
sys_exec(void)
{
80106549:	55                   	push   %ebp
8010654a:	89 e5                	mov    %esp,%ebp
8010654c:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106552:	83 ec 08             	sub    $0x8,%esp
80106555:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106558:	50                   	push   %eax
80106559:	6a 00                	push   $0x0
8010655b:	e8 9c f3 ff ff       	call   801058fc <argstr>
80106560:	83 c4 10             	add    $0x10,%esp
80106563:	85 c0                	test   %eax,%eax
80106565:	78 18                	js     8010657f <sys_exec+0x36>
80106567:	83 ec 08             	sub    $0x8,%esp
8010656a:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106570:	50                   	push   %eax
80106571:	6a 01                	push   $0x1
80106573:	e8 ff f2 ff ff       	call   80105877 <argint>
80106578:	83 c4 10             	add    $0x10,%esp
8010657b:	85 c0                	test   %eax,%eax
8010657d:	79 0a                	jns    80106589 <sys_exec+0x40>
    return -1;
8010657f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106584:	e9 c6 00 00 00       	jmp    8010664f <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106589:	83 ec 04             	sub    $0x4,%esp
8010658c:	68 80 00 00 00       	push   $0x80
80106591:	6a 00                	push   $0x0
80106593:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106599:	50                   	push   %eax
8010659a:	e8 b3 ef ff ff       	call   80105552 <memset>
8010659f:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801065a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801065a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ac:	83 f8 1f             	cmp    $0x1f,%eax
801065af:	76 0a                	jbe    801065bb <sys_exec+0x72>
      return -1;
801065b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b6:	e9 94 00 00 00       	jmp    8010664f <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801065bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065be:	c1 e0 02             	shl    $0x2,%eax
801065c1:	89 c2                	mov    %eax,%edx
801065c3:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065c9:	01 c2                	add    %eax,%edx
801065cb:	83 ec 08             	sub    $0x8,%esp
801065ce:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065d4:	50                   	push   %eax
801065d5:	52                   	push   %edx
801065d6:	e8 00 f2 ff ff       	call   801057db <fetchint>
801065db:	83 c4 10             	add    $0x10,%esp
801065de:	85 c0                	test   %eax,%eax
801065e0:	79 07                	jns    801065e9 <sys_exec+0xa0>
      return -1;
801065e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e7:	eb 66                	jmp    8010664f <sys_exec+0x106>
    if(uarg == 0){
801065e9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801065ef:	85 c0                	test   %eax,%eax
801065f1:	75 27                	jne    8010661a <sys_exec+0xd1>
      argv[i] = 0;
801065f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f6:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801065fd:	00 00 00 00 
      break;
80106601:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106605:	83 ec 08             	sub    $0x8,%esp
80106608:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010660e:	52                   	push   %edx
8010660f:	50                   	push   %eax
80106610:	e8 5c a5 ff ff       	call   80100b71 <exec>
80106615:	83 c4 10             	add    $0x10,%esp
80106618:	eb 35                	jmp    8010664f <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010661a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106620:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106623:	c1 e2 02             	shl    $0x2,%edx
80106626:	01 c2                	add    %eax,%edx
80106628:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010662e:	83 ec 08             	sub    $0x8,%esp
80106631:	52                   	push   %edx
80106632:	50                   	push   %eax
80106633:	e8 dd f1 ff ff       	call   80105815 <fetchstr>
80106638:	83 c4 10             	add    $0x10,%esp
8010663b:	85 c0                	test   %eax,%eax
8010663d:	79 07                	jns    80106646 <sys_exec+0xfd>
      return -1;
8010663f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106644:	eb 09                	jmp    8010664f <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106646:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010664a:	e9 5a ff ff ff       	jmp    801065a9 <sys_exec+0x60>
  return exec(path, argv);
}
8010664f:	c9                   	leave  
80106650:	c3                   	ret    

80106651 <sys_pipe>:

int
sys_pipe(void)
{
80106651:	55                   	push   %ebp
80106652:	89 e5                	mov    %esp,%ebp
80106654:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106657:	83 ec 04             	sub    $0x4,%esp
8010665a:	6a 08                	push   $0x8
8010665c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010665f:	50                   	push   %eax
80106660:	6a 00                	push   $0x0
80106662:	e8 38 f2 ff ff       	call   8010589f <argptr>
80106667:	83 c4 10             	add    $0x10,%esp
8010666a:	85 c0                	test   %eax,%eax
8010666c:	79 0a                	jns    80106678 <sys_pipe+0x27>
    return -1;
8010666e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106673:	e9 af 00 00 00       	jmp    80106727 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106678:	83 ec 08             	sub    $0x8,%esp
8010667b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010667e:	50                   	push   %eax
8010667f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106682:	50                   	push   %eax
80106683:	e8 b9 d9 ff ff       	call   80104041 <pipealloc>
80106688:	83 c4 10             	add    $0x10,%esp
8010668b:	85 c0                	test   %eax,%eax
8010668d:	79 0a                	jns    80106699 <sys_pipe+0x48>
    return -1;
8010668f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106694:	e9 8e 00 00 00       	jmp    80106727 <sys_pipe+0xd6>
  fd0 = -1;
80106699:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801066a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066a3:	83 ec 0c             	sub    $0xc,%esp
801066a6:	50                   	push   %eax
801066a7:	e8 7c f3 ff ff       	call   80105a28 <fdalloc>
801066ac:	83 c4 10             	add    $0x10,%esp
801066af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066b6:	78 18                	js     801066d0 <sys_pipe+0x7f>
801066b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066bb:	83 ec 0c             	sub    $0xc,%esp
801066be:	50                   	push   %eax
801066bf:	e8 64 f3 ff ff       	call   80105a28 <fdalloc>
801066c4:	83 c4 10             	add    $0x10,%esp
801066c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066ce:	79 3f                	jns    8010670f <sys_pipe+0xbe>
    if(fd0 >= 0)
801066d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066d4:	78 14                	js     801066ea <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
801066d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066df:	83 c2 08             	add    $0x8,%edx
801066e2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801066e9:	00 
    fileclose(rf);
801066ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066ed:	83 ec 0c             	sub    $0xc,%esp
801066f0:	50                   	push   %eax
801066f1:	e8 5b a9 ff ff       	call   80101051 <fileclose>
801066f6:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801066f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066fc:	83 ec 0c             	sub    $0xc,%esp
801066ff:	50                   	push   %eax
80106700:	e8 4c a9 ff ff       	call   80101051 <fileclose>
80106705:	83 c4 10             	add    $0x10,%esp
    return -1;
80106708:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010670d:	eb 18                	jmp    80106727 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
8010670f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106712:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106715:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106717:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010671a:	8d 50 04             	lea    0x4(%eax),%edx
8010671d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106720:	89 02                	mov    %eax,(%edx)
  return 0;
80106722:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106727:	c9                   	leave  
80106728:	c3                   	ret    

80106729 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106729:	55                   	push   %ebp
8010672a:	89 e5                	mov    %esp,%ebp
8010672c:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010672f:	e8 51 e0 ff ff       	call   80104785 <fork>
}
80106734:	c9                   	leave  
80106735:	c3                   	ret    

80106736 <sys_exit>:

int
sys_exit(void)
{
80106736:	55                   	push   %ebp
80106737:	89 e5                	mov    %esp,%ebp
80106739:	83 ec 08             	sub    $0x8,%esp
  exit();
8010673c:	e8 d5 e1 ff ff       	call   80104916 <exit>
  return 0;  // not reached
80106741:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106746:	c9                   	leave  
80106747:	c3                   	ret    

80106748 <sys_wait>:

int
sys_wait(void)
{
80106748:	55                   	push   %ebp
80106749:	89 e5                	mov    %esp,%ebp
8010674b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010674e:	e8 fe e2 ff ff       	call   80104a51 <wait>
}
80106753:	c9                   	leave  
80106754:	c3                   	ret    

80106755 <sys_kill>:

int
sys_kill(void)
{
80106755:	55                   	push   %ebp
80106756:	89 e5                	mov    %esp,%ebp
80106758:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010675b:	83 ec 08             	sub    $0x8,%esp
8010675e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106761:	50                   	push   %eax
80106762:	6a 00                	push   $0x0
80106764:	e8 0e f1 ff ff       	call   80105877 <argint>
80106769:	83 c4 10             	add    $0x10,%esp
8010676c:	85 c0                	test   %eax,%eax
8010676e:	79 07                	jns    80106777 <sys_kill+0x22>
    return -1;
80106770:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106775:	eb 0f                	jmp    80106786 <sys_kill+0x31>
  return kill(pid);
80106777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677a:	83 ec 0c             	sub    $0xc,%esp
8010677d:	50                   	push   %eax
8010677e:	e8 8f e9 ff ff       	call   80105112 <kill>
80106783:	83 c4 10             	add    $0x10,%esp
}
80106786:	c9                   	leave  
80106787:	c3                   	ret    

80106788 <sys_getpid>:

int
sys_getpid(void)
{
80106788:	55                   	push   %ebp
80106789:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010678b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106791:	8b 40 10             	mov    0x10(%eax),%eax
}
80106794:	5d                   	pop    %ebp
80106795:	c3                   	ret    

80106796 <sys_sbrk>:

int
sys_sbrk(void)
{
80106796:	55                   	push   %ebp
80106797:	89 e5                	mov    %esp,%ebp
80106799:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010679c:	83 ec 08             	sub    $0x8,%esp
8010679f:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067a2:	50                   	push   %eax
801067a3:	6a 00                	push   $0x0
801067a5:	e8 cd f0 ff ff       	call   80105877 <argint>
801067aa:	83 c4 10             	add    $0x10,%esp
801067ad:	85 c0                	test   %eax,%eax
801067af:	79 07                	jns    801067b8 <sys_sbrk+0x22>
    return -1;
801067b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b6:	eb 28                	jmp    801067e0 <sys_sbrk+0x4a>
  addr = proc->sz;
801067b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067be:	8b 00                	mov    (%eax),%eax
801067c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801067c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067c6:	83 ec 0c             	sub    $0xc,%esp
801067c9:	50                   	push   %eax
801067ca:	e8 13 df ff ff       	call   801046e2 <growproc>
801067cf:	83 c4 10             	add    $0x10,%esp
801067d2:	85 c0                	test   %eax,%eax
801067d4:	79 07                	jns    801067dd <sys_sbrk+0x47>
    return -1;
801067d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067db:	eb 03                	jmp    801067e0 <sys_sbrk+0x4a>
  return addr;
801067dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067e0:	c9                   	leave  
801067e1:	c3                   	ret    

801067e2 <sys_sleep>:

int
sys_sleep(void)
{
801067e2:	55                   	push   %ebp
801067e3:	89 e5                	mov    %esp,%ebp
801067e5:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801067e8:	83 ec 08             	sub    $0x8,%esp
801067eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067ee:	50                   	push   %eax
801067ef:	6a 00                	push   $0x0
801067f1:	e8 81 f0 ff ff       	call   80105877 <argint>
801067f6:	83 c4 10             	add    $0x10,%esp
801067f9:	85 c0                	test   %eax,%eax
801067fb:	79 07                	jns    80106804 <sys_sleep+0x22>
    return -1;
801067fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106802:	eb 77                	jmp    8010687b <sys_sleep+0x99>
  acquire(&tickslock);
80106804:	83 ec 0c             	sub    $0xc,%esp
80106807:	68 a0 4d 11 80       	push   $0x80114da0
8010680c:	e8 de ea ff ff       	call   801052ef <acquire>
80106811:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106814:	a1 e0 55 11 80       	mov    0x801155e0,%eax
80106819:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010681c:	eb 39                	jmp    80106857 <sys_sleep+0x75>
    if(proc->killed){
8010681e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106824:	8b 40 24             	mov    0x24(%eax),%eax
80106827:	85 c0                	test   %eax,%eax
80106829:	74 17                	je     80106842 <sys_sleep+0x60>
      release(&tickslock);
8010682b:	83 ec 0c             	sub    $0xc,%esp
8010682e:	68 a0 4d 11 80       	push   $0x80114da0
80106833:	e8 1e eb ff ff       	call   80105356 <release>
80106838:	83 c4 10             	add    $0x10,%esp
      return -1;
8010683b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106840:	eb 39                	jmp    8010687b <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106842:	83 ec 08             	sub    $0x8,%esp
80106845:	68 a0 4d 11 80       	push   $0x80114da0
8010684a:	68 e0 55 11 80       	push   $0x801155e0
8010684f:	e8 99 e7 ff ff       	call   80104fed <sleep>
80106854:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106857:	a1 e0 55 11 80       	mov    0x801155e0,%eax
8010685c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010685f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106862:	39 d0                	cmp    %edx,%eax
80106864:	72 b8                	jb     8010681e <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106866:	83 ec 0c             	sub    $0xc,%esp
80106869:	68 a0 4d 11 80       	push   $0x80114da0
8010686e:	e8 e3 ea ff ff       	call   80105356 <release>
80106873:	83 c4 10             	add    $0x10,%esp
  return 0;
80106876:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010687b:	c9                   	leave  
8010687c:	c3                   	ret    

8010687d <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010687d:	55                   	push   %ebp
8010687e:	89 e5                	mov    %esp,%ebp
80106880:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106883:	83 ec 0c             	sub    $0xc,%esp
80106886:	68 a0 4d 11 80       	push   $0x80114da0
8010688b:	e8 5f ea ff ff       	call   801052ef <acquire>
80106890:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106893:	a1 e0 55 11 80       	mov    0x801155e0,%eax
80106898:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010689b:	83 ec 0c             	sub    $0xc,%esp
8010689e:	68 a0 4d 11 80       	push   $0x80114da0
801068a3:	e8 ae ea ff ff       	call   80105356 <release>
801068a8:	83 c4 10             	add    $0x10,%esp
  return xticks;
801068ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068ae:	c9                   	leave  
801068af:	c3                   	ret    

801068b0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801068b0:	55                   	push   %ebp
801068b1:	89 e5                	mov    %esp,%ebp
801068b3:	83 ec 08             	sub    $0x8,%esp
801068b6:	8b 55 08             	mov    0x8(%ebp),%edx
801068b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801068bc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801068c0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068c3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068c7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068cb:	ee                   	out    %al,(%dx)
}
801068cc:	90                   	nop
801068cd:	c9                   	leave  
801068ce:	c3                   	ret    

801068cf <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801068cf:	55                   	push   %ebp
801068d0:	89 e5                	mov    %esp,%ebp
801068d2:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801068d5:	6a 34                	push   $0x34
801068d7:	6a 43                	push   $0x43
801068d9:	e8 d2 ff ff ff       	call   801068b0 <outb>
801068de:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801068e1:	68 9c 00 00 00       	push   $0x9c
801068e6:	6a 40                	push   $0x40
801068e8:	e8 c3 ff ff ff       	call   801068b0 <outb>
801068ed:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801068f0:	6a 2e                	push   $0x2e
801068f2:	6a 40                	push   $0x40
801068f4:	e8 b7 ff ff ff       	call   801068b0 <outb>
801068f9:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801068fc:	83 ec 0c             	sub    $0xc,%esp
801068ff:	6a 00                	push   $0x0
80106901:	e8 25 d6 ff ff       	call   80103f2b <picenable>
80106906:	83 c4 10             	add    $0x10,%esp
}
80106909:	90                   	nop
8010690a:	c9                   	leave  
8010690b:	c3                   	ret    

8010690c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010690c:	1e                   	push   %ds
  pushl %es
8010690d:	06                   	push   %es
  pushl %fs
8010690e:	0f a0                	push   %fs
  pushl %gs
80106910:	0f a8                	push   %gs
  pushal
80106912:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106913:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106917:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106919:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010691b:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010691f:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106921:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106923:	54                   	push   %esp
  call trap
80106924:	e8 d7 01 00 00       	call   80106b00 <trap>
  addl $4, %esp
80106929:	83 c4 04             	add    $0x4,%esp

8010692c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010692c:	61                   	popa   
  popl %gs
8010692d:	0f a9                	pop    %gs
  popl %fs
8010692f:	0f a1                	pop    %fs
  popl %es
80106931:	07                   	pop    %es
  popl %ds
80106932:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106933:	83 c4 08             	add    $0x8,%esp
  iret
80106936:	cf                   	iret   

80106937 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106937:	55                   	push   %ebp
80106938:	89 e5                	mov    %esp,%ebp
8010693a:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010693d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106940:	83 e8 01             	sub    $0x1,%eax
80106943:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106947:	8b 45 08             	mov    0x8(%ebp),%eax
8010694a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010694e:	8b 45 08             	mov    0x8(%ebp),%eax
80106951:	c1 e8 10             	shr    $0x10,%eax
80106954:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106958:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010695b:	0f 01 18             	lidtl  (%eax)
}
8010695e:	90                   	nop
8010695f:	c9                   	leave  
80106960:	c3                   	ret    

80106961 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106961:	55                   	push   %ebp
80106962:	89 e5                	mov    %esp,%ebp
80106964:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106967:	0f 20 d0             	mov    %cr2,%eax
8010696a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010696d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106970:	c9                   	leave  
80106971:	c3                   	ret    

80106972 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106972:	55                   	push   %ebp
80106973:	89 e5                	mov    %esp,%ebp
80106975:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106978:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010697f:	e9 c3 00 00 00       	jmp    80106a47 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106987:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
8010698e:	89 c2                	mov    %eax,%edx
80106990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106993:	66 89 14 c5 e0 4d 11 	mov    %dx,-0x7feeb220(,%eax,8)
8010699a:	80 
8010699b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699e:	66 c7 04 c5 e2 4d 11 	movw   $0x8,-0x7feeb21e(,%eax,8)
801069a5:	80 08 00 
801069a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ab:	0f b6 14 c5 e4 4d 11 	movzbl -0x7feeb21c(,%eax,8),%edx
801069b2:	80 
801069b3:	83 e2 e0             	and    $0xffffffe0,%edx
801069b6:	88 14 c5 e4 4d 11 80 	mov    %dl,-0x7feeb21c(,%eax,8)
801069bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c0:	0f b6 14 c5 e4 4d 11 	movzbl -0x7feeb21c(,%eax,8),%edx
801069c7:	80 
801069c8:	83 e2 1f             	and    $0x1f,%edx
801069cb:	88 14 c5 e4 4d 11 80 	mov    %dl,-0x7feeb21c(,%eax,8)
801069d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d5:	0f b6 14 c5 e5 4d 11 	movzbl -0x7feeb21b(,%eax,8),%edx
801069dc:	80 
801069dd:	83 e2 f0             	and    $0xfffffff0,%edx
801069e0:	83 ca 0e             	or     $0xe,%edx
801069e3:	88 14 c5 e5 4d 11 80 	mov    %dl,-0x7feeb21b(,%eax,8)
801069ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ed:	0f b6 14 c5 e5 4d 11 	movzbl -0x7feeb21b(,%eax,8),%edx
801069f4:	80 
801069f5:	83 e2 ef             	and    $0xffffffef,%edx
801069f8:	88 14 c5 e5 4d 11 80 	mov    %dl,-0x7feeb21b(,%eax,8)
801069ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a02:	0f b6 14 c5 e5 4d 11 	movzbl -0x7feeb21b(,%eax,8),%edx
80106a09:	80 
80106a0a:	83 e2 9f             	and    $0xffffff9f,%edx
80106a0d:	88 14 c5 e5 4d 11 80 	mov    %dl,-0x7feeb21b(,%eax,8)
80106a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a17:	0f b6 14 c5 e5 4d 11 	movzbl -0x7feeb21b(,%eax,8),%edx
80106a1e:	80 
80106a1f:	83 ca 80             	or     $0xffffff80,%edx
80106a22:	88 14 c5 e5 4d 11 80 	mov    %dl,-0x7feeb21b(,%eax,8)
80106a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2c:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106a33:	c1 e8 10             	shr    $0x10,%eax
80106a36:	89 c2                	mov    %eax,%edx
80106a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3b:	66 89 14 c5 e6 4d 11 	mov    %dx,-0x7feeb21a(,%eax,8)
80106a42:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106a43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a47:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a4e:	0f 8e 30 ff ff ff    	jle    80106984 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a54:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106a59:	66 a3 e0 4f 11 80    	mov    %ax,0x80114fe0
80106a5f:	66 c7 05 e2 4f 11 80 	movw   $0x8,0x80114fe2
80106a66:	08 00 
80106a68:	0f b6 05 e4 4f 11 80 	movzbl 0x80114fe4,%eax
80106a6f:	83 e0 e0             	and    $0xffffffe0,%eax
80106a72:	a2 e4 4f 11 80       	mov    %al,0x80114fe4
80106a77:	0f b6 05 e4 4f 11 80 	movzbl 0x80114fe4,%eax
80106a7e:	83 e0 1f             	and    $0x1f,%eax
80106a81:	a2 e4 4f 11 80       	mov    %al,0x80114fe4
80106a86:	0f b6 05 e5 4f 11 80 	movzbl 0x80114fe5,%eax
80106a8d:	83 c8 0f             	or     $0xf,%eax
80106a90:	a2 e5 4f 11 80       	mov    %al,0x80114fe5
80106a95:	0f b6 05 e5 4f 11 80 	movzbl 0x80114fe5,%eax
80106a9c:	83 e0 ef             	and    $0xffffffef,%eax
80106a9f:	a2 e5 4f 11 80       	mov    %al,0x80114fe5
80106aa4:	0f b6 05 e5 4f 11 80 	movzbl 0x80114fe5,%eax
80106aab:	83 c8 60             	or     $0x60,%eax
80106aae:	a2 e5 4f 11 80       	mov    %al,0x80114fe5
80106ab3:	0f b6 05 e5 4f 11 80 	movzbl 0x80114fe5,%eax
80106aba:	83 c8 80             	or     $0xffffff80,%eax
80106abd:	a2 e5 4f 11 80       	mov    %al,0x80114fe5
80106ac2:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106ac7:	c1 e8 10             	shr    $0x10,%eax
80106aca:	66 a3 e6 4f 11 80    	mov    %ax,0x80114fe6
  
  initlock(&tickslock, "time");
80106ad0:	83 ec 08             	sub    $0x8,%esp
80106ad3:	68 18 8d 10 80       	push   $0x80108d18
80106ad8:	68 a0 4d 11 80       	push   $0x80114da0
80106add:	e8 eb e7 ff ff       	call   801052cd <initlock>
80106ae2:	83 c4 10             	add    $0x10,%esp
}
80106ae5:	90                   	nop
80106ae6:	c9                   	leave  
80106ae7:	c3                   	ret    

80106ae8 <idtinit>:

void
idtinit(void)
{
80106ae8:	55                   	push   %ebp
80106ae9:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106aeb:	68 00 08 00 00       	push   $0x800
80106af0:	68 e0 4d 11 80       	push   $0x80114de0
80106af5:	e8 3d fe ff ff       	call   80106937 <lidt>
80106afa:	83 c4 08             	add    $0x8,%esp
}
80106afd:	90                   	nop
80106afe:	c9                   	leave  
80106aff:	c3                   	ret    

80106b00 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106b00:	55                   	push   %ebp
80106b01:	89 e5                	mov    %esp,%ebp
80106b03:	57                   	push   %edi
80106b04:	56                   	push   %esi
80106b05:	53                   	push   %ebx
80106b06:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106b09:	8b 45 08             	mov    0x8(%ebp),%eax
80106b0c:	8b 40 30             	mov    0x30(%eax),%eax
80106b0f:	83 f8 40             	cmp    $0x40,%eax
80106b12:	75 3e                	jne    80106b52 <trap+0x52>
    if(proc->killed)
80106b14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b1a:	8b 40 24             	mov    0x24(%eax),%eax
80106b1d:	85 c0                	test   %eax,%eax
80106b1f:	74 05                	je     80106b26 <trap+0x26>
      exit();
80106b21:	e8 f0 dd ff ff       	call   80104916 <exit>
    proc->tf = tf;
80106b26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b2c:	8b 55 08             	mov    0x8(%ebp),%edx
80106b2f:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106b32:	e8 f6 ed ff ff       	call   8010592d <syscall>
    if(proc->killed)
80106b37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b3d:	8b 40 24             	mov    0x24(%eax),%eax
80106b40:	85 c0                	test   %eax,%eax
80106b42:	0f 84 1b 02 00 00    	je     80106d63 <trap+0x263>
      exit();
80106b48:	e8 c9 dd ff ff       	call   80104916 <exit>
    return;
80106b4d:	e9 11 02 00 00       	jmp    80106d63 <trap+0x263>
  }

  switch(tf->trapno){
80106b52:	8b 45 08             	mov    0x8(%ebp),%eax
80106b55:	8b 40 30             	mov    0x30(%eax),%eax
80106b58:	83 e8 20             	sub    $0x20,%eax
80106b5b:	83 f8 1f             	cmp    $0x1f,%eax
80106b5e:	0f 87 c0 00 00 00    	ja     80106c24 <trap+0x124>
80106b64:	8b 04 85 c0 8d 10 80 	mov    -0x7fef7240(,%eax,4),%eax
80106b6b:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b73:	0f b6 00             	movzbl (%eax),%eax
80106b76:	84 c0                	test   %al,%al
80106b78:	75 3d                	jne    80106bb7 <trap+0xb7>
      acquire(&tickslock);
80106b7a:	83 ec 0c             	sub    $0xc,%esp
80106b7d:	68 a0 4d 11 80       	push   $0x80114da0
80106b82:	e8 68 e7 ff ff       	call   801052ef <acquire>
80106b87:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106b8a:	a1 e0 55 11 80       	mov    0x801155e0,%eax
80106b8f:	83 c0 01             	add    $0x1,%eax
80106b92:	a3 e0 55 11 80       	mov    %eax,0x801155e0
      wakeup(&ticks);
80106b97:	83 ec 0c             	sub    $0xc,%esp
80106b9a:	68 e0 55 11 80       	push   $0x801155e0
80106b9f:	e8 37 e5 ff ff       	call   801050db <wakeup>
80106ba4:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106ba7:	83 ec 0c             	sub    $0xc,%esp
80106baa:	68 a0 4d 11 80       	push   $0x80114da0
80106baf:	e8 a2 e7 ff ff       	call   80105356 <release>
80106bb4:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106bb7:	e8 69 c4 ff ff       	call   80103025 <lapiceoi>
    break;
80106bbc:	e9 1c 01 00 00       	jmp    80106cdd <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106bc1:	e8 72 bc ff ff       	call   80102838 <ideintr>
    lapiceoi();
80106bc6:	e8 5a c4 ff ff       	call   80103025 <lapiceoi>
    break;
80106bcb:	e9 0d 01 00 00       	jmp    80106cdd <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bd0:	e8 52 c2 ff ff       	call   80102e27 <kbdintr>
    lapiceoi();
80106bd5:	e8 4b c4 ff ff       	call   80103025 <lapiceoi>
    break;
80106bda:	e9 fe 00 00 00       	jmp    80106cdd <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106bdf:	e8 60 03 00 00       	call   80106f44 <uartintr>
    lapiceoi();
80106be4:	e8 3c c4 ff ff       	call   80103025 <lapiceoi>
    break;
80106be9:	e9 ef 00 00 00       	jmp    80106cdd <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bee:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf1:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bfb:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bfe:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c04:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c07:	0f b6 c0             	movzbl %al,%eax
80106c0a:	51                   	push   %ecx
80106c0b:	52                   	push   %edx
80106c0c:	50                   	push   %eax
80106c0d:	68 20 8d 10 80       	push   $0x80108d20
80106c12:	e8 af 97 ff ff       	call   801003c6 <cprintf>
80106c17:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106c1a:	e8 06 c4 ff ff       	call   80103025 <lapiceoi>
    break;
80106c1f:	e9 b9 00 00 00       	jmp    80106cdd <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c2a:	85 c0                	test   %eax,%eax
80106c2c:	74 11                	je     80106c3f <trap+0x13f>
80106c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c31:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c35:	0f b7 c0             	movzwl %ax,%eax
80106c38:	83 e0 03             	and    $0x3,%eax
80106c3b:	85 c0                	test   %eax,%eax
80106c3d:	75 40                	jne    80106c7f <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c3f:	e8 1d fd ff ff       	call   80106961 <rcr2>
80106c44:	89 c3                	mov    %eax,%ebx
80106c46:	8b 45 08             	mov    0x8(%ebp),%eax
80106c49:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c52:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c55:	0f b6 d0             	movzbl %al,%edx
80106c58:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5b:	8b 40 30             	mov    0x30(%eax),%eax
80106c5e:	83 ec 0c             	sub    $0xc,%esp
80106c61:	53                   	push   %ebx
80106c62:	51                   	push   %ecx
80106c63:	52                   	push   %edx
80106c64:	50                   	push   %eax
80106c65:	68 44 8d 10 80       	push   $0x80108d44
80106c6a:	e8 57 97 ff ff       	call   801003c6 <cprintf>
80106c6f:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c72:	83 ec 0c             	sub    $0xc,%esp
80106c75:	68 76 8d 10 80       	push   $0x80108d76
80106c7a:	e8 e7 98 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c7f:	e8 dd fc ff ff       	call   80106961 <rcr2>
80106c84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c87:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8a:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c8d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c93:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c96:	0f b6 d8             	movzbl %al,%ebx
80106c99:	8b 45 08             	mov    0x8(%ebp),%eax
80106c9c:	8b 48 34             	mov    0x34(%eax),%ecx
80106c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca2:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ca5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cab:	8d 78 6c             	lea    0x6c(%eax),%edi
80106cae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cb4:	8b 40 10             	mov    0x10(%eax),%eax
80106cb7:	ff 75 e4             	pushl  -0x1c(%ebp)
80106cba:	56                   	push   %esi
80106cbb:	53                   	push   %ebx
80106cbc:	51                   	push   %ecx
80106cbd:	52                   	push   %edx
80106cbe:	57                   	push   %edi
80106cbf:	50                   	push   %eax
80106cc0:	68 7c 8d 10 80       	push   $0x80108d7c
80106cc5:	e8 fc 96 ff ff       	call   801003c6 <cprintf>
80106cca:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106ccd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cd3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cda:	eb 01                	jmp    80106cdd <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106cdc:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cdd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ce3:	85 c0                	test   %eax,%eax
80106ce5:	74 24                	je     80106d0b <trap+0x20b>
80106ce7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ced:	8b 40 24             	mov    0x24(%eax),%eax
80106cf0:	85 c0                	test   %eax,%eax
80106cf2:	74 17                	je     80106d0b <trap+0x20b>
80106cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80106cf7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cfb:	0f b7 c0             	movzwl %ax,%eax
80106cfe:	83 e0 03             	and    $0x3,%eax
80106d01:	83 f8 03             	cmp    $0x3,%eax
80106d04:	75 05                	jne    80106d0b <trap+0x20b>
    exit();
80106d06:	e8 0b dc ff ff       	call   80104916 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106d0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d11:	85 c0                	test   %eax,%eax
80106d13:	74 1e                	je     80106d33 <trap+0x233>
80106d15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d1b:	8b 40 0c             	mov    0xc(%eax),%eax
80106d1e:	83 f8 04             	cmp    $0x4,%eax
80106d21:	75 10                	jne    80106d33 <trap+0x233>
80106d23:	8b 45 08             	mov    0x8(%ebp),%eax
80106d26:	8b 40 30             	mov    0x30(%eax),%eax
80106d29:	83 f8 20             	cmp    $0x20,%eax
80106d2c:	75 05                	jne    80106d33 <trap+0x233>
    yield();
80106d2e:	e8 39 e2 ff ff       	call   80104f6c <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d39:	85 c0                	test   %eax,%eax
80106d3b:	74 27                	je     80106d64 <trap+0x264>
80106d3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d43:	8b 40 24             	mov    0x24(%eax),%eax
80106d46:	85 c0                	test   %eax,%eax
80106d48:	74 1a                	je     80106d64 <trap+0x264>
80106d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d4d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d51:	0f b7 c0             	movzwl %ax,%eax
80106d54:	83 e0 03             	and    $0x3,%eax
80106d57:	83 f8 03             	cmp    $0x3,%eax
80106d5a:	75 08                	jne    80106d64 <trap+0x264>
    exit();
80106d5c:	e8 b5 db ff ff       	call   80104916 <exit>
80106d61:	eb 01                	jmp    80106d64 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106d63:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d67:	5b                   	pop    %ebx
80106d68:	5e                   	pop    %esi
80106d69:	5f                   	pop    %edi
80106d6a:	5d                   	pop    %ebp
80106d6b:	c3                   	ret    

80106d6c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d6c:	55                   	push   %ebp
80106d6d:	89 e5                	mov    %esp,%ebp
80106d6f:	83 ec 14             	sub    $0x14,%esp
80106d72:	8b 45 08             	mov    0x8(%ebp),%eax
80106d75:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d79:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d7d:	89 c2                	mov    %eax,%edx
80106d7f:	ec                   	in     (%dx),%al
80106d80:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106d83:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106d87:	c9                   	leave  
80106d88:	c3                   	ret    

80106d89 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106d89:	55                   	push   %ebp
80106d8a:	89 e5                	mov    %esp,%ebp
80106d8c:	83 ec 08             	sub    $0x8,%esp
80106d8f:	8b 55 08             	mov    0x8(%ebp),%edx
80106d92:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d95:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d99:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d9c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106da0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106da4:	ee                   	out    %al,(%dx)
}
80106da5:	90                   	nop
80106da6:	c9                   	leave  
80106da7:	c3                   	ret    

80106da8 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106da8:	55                   	push   %ebp
80106da9:	89 e5                	mov    %esp,%ebp
80106dab:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106dae:	6a 00                	push   $0x0
80106db0:	68 fa 03 00 00       	push   $0x3fa
80106db5:	e8 cf ff ff ff       	call   80106d89 <outb>
80106dba:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106dbd:	68 80 00 00 00       	push   $0x80
80106dc2:	68 fb 03 00 00       	push   $0x3fb
80106dc7:	e8 bd ff ff ff       	call   80106d89 <outb>
80106dcc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106dcf:	6a 0c                	push   $0xc
80106dd1:	68 f8 03 00 00       	push   $0x3f8
80106dd6:	e8 ae ff ff ff       	call   80106d89 <outb>
80106ddb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106dde:	6a 00                	push   $0x0
80106de0:	68 f9 03 00 00       	push   $0x3f9
80106de5:	e8 9f ff ff ff       	call   80106d89 <outb>
80106dea:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ded:	6a 03                	push   $0x3
80106def:	68 fb 03 00 00       	push   $0x3fb
80106df4:	e8 90 ff ff ff       	call   80106d89 <outb>
80106df9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106dfc:	6a 00                	push   $0x0
80106dfe:	68 fc 03 00 00       	push   $0x3fc
80106e03:	e8 81 ff ff ff       	call   80106d89 <outb>
80106e08:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e0b:	6a 01                	push   $0x1
80106e0d:	68 f9 03 00 00       	push   $0x3f9
80106e12:	e8 72 ff ff ff       	call   80106d89 <outb>
80106e17:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e1a:	68 fd 03 00 00       	push   $0x3fd
80106e1f:	e8 48 ff ff ff       	call   80106d6c <inb>
80106e24:	83 c4 04             	add    $0x4,%esp
80106e27:	3c ff                	cmp    $0xff,%al
80106e29:	74 6e                	je     80106e99 <uartinit+0xf1>
    return;
  uart = 1;
80106e2b:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106e32:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e35:	68 fa 03 00 00       	push   $0x3fa
80106e3a:	e8 2d ff ff ff       	call   80106d6c <inb>
80106e3f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106e42:	68 f8 03 00 00       	push   $0x3f8
80106e47:	e8 20 ff ff ff       	call   80106d6c <inb>
80106e4c:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106e4f:	83 ec 0c             	sub    $0xc,%esp
80106e52:	6a 04                	push   $0x4
80106e54:	e8 d2 d0 ff ff       	call   80103f2b <picenable>
80106e59:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106e5c:	83 ec 08             	sub    $0x8,%esp
80106e5f:	6a 00                	push   $0x0
80106e61:	6a 04                	push   $0x4
80106e63:	e8 72 bc ff ff       	call   80102ada <ioapicenable>
80106e68:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e6b:	c7 45 f4 40 8e 10 80 	movl   $0x80108e40,-0xc(%ebp)
80106e72:	eb 19                	jmp    80106e8d <uartinit+0xe5>
    uartputc(*p);
80106e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e77:	0f b6 00             	movzbl (%eax),%eax
80106e7a:	0f be c0             	movsbl %al,%eax
80106e7d:	83 ec 0c             	sub    $0xc,%esp
80106e80:	50                   	push   %eax
80106e81:	e8 16 00 00 00       	call   80106e9c <uartputc>
80106e86:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e89:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e90:	0f b6 00             	movzbl (%eax),%eax
80106e93:	84 c0                	test   %al,%al
80106e95:	75 dd                	jne    80106e74 <uartinit+0xcc>
80106e97:	eb 01                	jmp    80106e9a <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106e99:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106e9a:	c9                   	leave  
80106e9b:	c3                   	ret    

80106e9c <uartputc>:

void
uartputc(int c)
{
80106e9c:	55                   	push   %ebp
80106e9d:	89 e5                	mov    %esp,%ebp
80106e9f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106ea2:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106ea7:	85 c0                	test   %eax,%eax
80106ea9:	74 53                	je     80106efe <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106eab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106eb2:	eb 11                	jmp    80106ec5 <uartputc+0x29>
    microdelay(10);
80106eb4:	83 ec 0c             	sub    $0xc,%esp
80106eb7:	6a 0a                	push   $0xa
80106eb9:	e8 82 c1 ff ff       	call   80103040 <microdelay>
80106ebe:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ec1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ec5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ec9:	7f 1a                	jg     80106ee5 <uartputc+0x49>
80106ecb:	83 ec 0c             	sub    $0xc,%esp
80106ece:	68 fd 03 00 00       	push   $0x3fd
80106ed3:	e8 94 fe ff ff       	call   80106d6c <inb>
80106ed8:	83 c4 10             	add    $0x10,%esp
80106edb:	0f b6 c0             	movzbl %al,%eax
80106ede:	83 e0 20             	and    $0x20,%eax
80106ee1:	85 c0                	test   %eax,%eax
80106ee3:	74 cf                	je     80106eb4 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee8:	0f b6 c0             	movzbl %al,%eax
80106eeb:	83 ec 08             	sub    $0x8,%esp
80106eee:	50                   	push   %eax
80106eef:	68 f8 03 00 00       	push   $0x3f8
80106ef4:	e8 90 fe ff ff       	call   80106d89 <outb>
80106ef9:	83 c4 10             	add    $0x10,%esp
80106efc:	eb 01                	jmp    80106eff <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106efe:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106eff:	c9                   	leave  
80106f00:	c3                   	ret    

80106f01 <uartgetc>:

static int
uartgetc(void)
{
80106f01:	55                   	push   %ebp
80106f02:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106f04:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f09:	85 c0                	test   %eax,%eax
80106f0b:	75 07                	jne    80106f14 <uartgetc+0x13>
    return -1;
80106f0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f12:	eb 2e                	jmp    80106f42 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106f14:	68 fd 03 00 00       	push   $0x3fd
80106f19:	e8 4e fe ff ff       	call   80106d6c <inb>
80106f1e:	83 c4 04             	add    $0x4,%esp
80106f21:	0f b6 c0             	movzbl %al,%eax
80106f24:	83 e0 01             	and    $0x1,%eax
80106f27:	85 c0                	test   %eax,%eax
80106f29:	75 07                	jne    80106f32 <uartgetc+0x31>
    return -1;
80106f2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f30:	eb 10                	jmp    80106f42 <uartgetc+0x41>
  return inb(COM1+0);
80106f32:	68 f8 03 00 00       	push   $0x3f8
80106f37:	e8 30 fe ff ff       	call   80106d6c <inb>
80106f3c:	83 c4 04             	add    $0x4,%esp
80106f3f:	0f b6 c0             	movzbl %al,%eax
}
80106f42:	c9                   	leave  
80106f43:	c3                   	ret    

80106f44 <uartintr>:

void
uartintr(void)
{
80106f44:	55                   	push   %ebp
80106f45:	89 e5                	mov    %esp,%ebp
80106f47:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106f4a:	83 ec 0c             	sub    $0xc,%esp
80106f4d:	68 01 6f 10 80       	push   $0x80106f01
80106f52:	e8 a2 98 ff ff       	call   801007f9 <consoleintr>
80106f57:	83 c4 10             	add    $0x10,%esp
}
80106f5a:	90                   	nop
80106f5b:	c9                   	leave  
80106f5c:	c3                   	ret    

80106f5d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $0
80106f5f:	6a 00                	push   $0x0
  jmp alltraps
80106f61:	e9 a6 f9 ff ff       	jmp    8010690c <alltraps>

80106f66 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $1
80106f68:	6a 01                	push   $0x1
  jmp alltraps
80106f6a:	e9 9d f9 ff ff       	jmp    8010690c <alltraps>

80106f6f <vector2>:
.globl vector2
vector2:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $2
80106f71:	6a 02                	push   $0x2
  jmp alltraps
80106f73:	e9 94 f9 ff ff       	jmp    8010690c <alltraps>

80106f78 <vector3>:
.globl vector3
vector3:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $3
80106f7a:	6a 03                	push   $0x3
  jmp alltraps
80106f7c:	e9 8b f9 ff ff       	jmp    8010690c <alltraps>

80106f81 <vector4>:
.globl vector4
vector4:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $4
80106f83:	6a 04                	push   $0x4
  jmp alltraps
80106f85:	e9 82 f9 ff ff       	jmp    8010690c <alltraps>

80106f8a <vector5>:
.globl vector5
vector5:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $5
80106f8c:	6a 05                	push   $0x5
  jmp alltraps
80106f8e:	e9 79 f9 ff ff       	jmp    8010690c <alltraps>

80106f93 <vector6>:
.globl vector6
vector6:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $6
80106f95:	6a 06                	push   $0x6
  jmp alltraps
80106f97:	e9 70 f9 ff ff       	jmp    8010690c <alltraps>

80106f9c <vector7>:
.globl vector7
vector7:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $7
80106f9e:	6a 07                	push   $0x7
  jmp alltraps
80106fa0:	e9 67 f9 ff ff       	jmp    8010690c <alltraps>

80106fa5 <vector8>:
.globl vector8
vector8:
  pushl $8
80106fa5:	6a 08                	push   $0x8
  jmp alltraps
80106fa7:	e9 60 f9 ff ff       	jmp    8010690c <alltraps>

80106fac <vector9>:
.globl vector9
vector9:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $9
80106fae:	6a 09                	push   $0x9
  jmp alltraps
80106fb0:	e9 57 f9 ff ff       	jmp    8010690c <alltraps>

80106fb5 <vector10>:
.globl vector10
vector10:
  pushl $10
80106fb5:	6a 0a                	push   $0xa
  jmp alltraps
80106fb7:	e9 50 f9 ff ff       	jmp    8010690c <alltraps>

80106fbc <vector11>:
.globl vector11
vector11:
  pushl $11
80106fbc:	6a 0b                	push   $0xb
  jmp alltraps
80106fbe:	e9 49 f9 ff ff       	jmp    8010690c <alltraps>

80106fc3 <vector12>:
.globl vector12
vector12:
  pushl $12
80106fc3:	6a 0c                	push   $0xc
  jmp alltraps
80106fc5:	e9 42 f9 ff ff       	jmp    8010690c <alltraps>

80106fca <vector13>:
.globl vector13
vector13:
  pushl $13
80106fca:	6a 0d                	push   $0xd
  jmp alltraps
80106fcc:	e9 3b f9 ff ff       	jmp    8010690c <alltraps>

80106fd1 <vector14>:
.globl vector14
vector14:
  pushl $14
80106fd1:	6a 0e                	push   $0xe
  jmp alltraps
80106fd3:	e9 34 f9 ff ff       	jmp    8010690c <alltraps>

80106fd8 <vector15>:
.globl vector15
vector15:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $15
80106fda:	6a 0f                	push   $0xf
  jmp alltraps
80106fdc:	e9 2b f9 ff ff       	jmp    8010690c <alltraps>

80106fe1 <vector16>:
.globl vector16
vector16:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $16
80106fe3:	6a 10                	push   $0x10
  jmp alltraps
80106fe5:	e9 22 f9 ff ff       	jmp    8010690c <alltraps>

80106fea <vector17>:
.globl vector17
vector17:
  pushl $17
80106fea:	6a 11                	push   $0x11
  jmp alltraps
80106fec:	e9 1b f9 ff ff       	jmp    8010690c <alltraps>

80106ff1 <vector18>:
.globl vector18
vector18:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $18
80106ff3:	6a 12                	push   $0x12
  jmp alltraps
80106ff5:	e9 12 f9 ff ff       	jmp    8010690c <alltraps>

80106ffa <vector19>:
.globl vector19
vector19:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $19
80106ffc:	6a 13                	push   $0x13
  jmp alltraps
80106ffe:	e9 09 f9 ff ff       	jmp    8010690c <alltraps>

80107003 <vector20>:
.globl vector20
vector20:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $20
80107005:	6a 14                	push   $0x14
  jmp alltraps
80107007:	e9 00 f9 ff ff       	jmp    8010690c <alltraps>

8010700c <vector21>:
.globl vector21
vector21:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $21
8010700e:	6a 15                	push   $0x15
  jmp alltraps
80107010:	e9 f7 f8 ff ff       	jmp    8010690c <alltraps>

80107015 <vector22>:
.globl vector22
vector22:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $22
80107017:	6a 16                	push   $0x16
  jmp alltraps
80107019:	e9 ee f8 ff ff       	jmp    8010690c <alltraps>

8010701e <vector23>:
.globl vector23
vector23:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $23
80107020:	6a 17                	push   $0x17
  jmp alltraps
80107022:	e9 e5 f8 ff ff       	jmp    8010690c <alltraps>

80107027 <vector24>:
.globl vector24
vector24:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $24
80107029:	6a 18                	push   $0x18
  jmp alltraps
8010702b:	e9 dc f8 ff ff       	jmp    8010690c <alltraps>

80107030 <vector25>:
.globl vector25
vector25:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $25
80107032:	6a 19                	push   $0x19
  jmp alltraps
80107034:	e9 d3 f8 ff ff       	jmp    8010690c <alltraps>

80107039 <vector26>:
.globl vector26
vector26:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $26
8010703b:	6a 1a                	push   $0x1a
  jmp alltraps
8010703d:	e9 ca f8 ff ff       	jmp    8010690c <alltraps>

80107042 <vector27>:
.globl vector27
vector27:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $27
80107044:	6a 1b                	push   $0x1b
  jmp alltraps
80107046:	e9 c1 f8 ff ff       	jmp    8010690c <alltraps>

8010704b <vector28>:
.globl vector28
vector28:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $28
8010704d:	6a 1c                	push   $0x1c
  jmp alltraps
8010704f:	e9 b8 f8 ff ff       	jmp    8010690c <alltraps>

80107054 <vector29>:
.globl vector29
vector29:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $29
80107056:	6a 1d                	push   $0x1d
  jmp alltraps
80107058:	e9 af f8 ff ff       	jmp    8010690c <alltraps>

8010705d <vector30>:
.globl vector30
vector30:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $30
8010705f:	6a 1e                	push   $0x1e
  jmp alltraps
80107061:	e9 a6 f8 ff ff       	jmp    8010690c <alltraps>

80107066 <vector31>:
.globl vector31
vector31:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $31
80107068:	6a 1f                	push   $0x1f
  jmp alltraps
8010706a:	e9 9d f8 ff ff       	jmp    8010690c <alltraps>

8010706f <vector32>:
.globl vector32
vector32:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $32
80107071:	6a 20                	push   $0x20
  jmp alltraps
80107073:	e9 94 f8 ff ff       	jmp    8010690c <alltraps>

80107078 <vector33>:
.globl vector33
vector33:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $33
8010707a:	6a 21                	push   $0x21
  jmp alltraps
8010707c:	e9 8b f8 ff ff       	jmp    8010690c <alltraps>

80107081 <vector34>:
.globl vector34
vector34:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $34
80107083:	6a 22                	push   $0x22
  jmp alltraps
80107085:	e9 82 f8 ff ff       	jmp    8010690c <alltraps>

8010708a <vector35>:
.globl vector35
vector35:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $35
8010708c:	6a 23                	push   $0x23
  jmp alltraps
8010708e:	e9 79 f8 ff ff       	jmp    8010690c <alltraps>

80107093 <vector36>:
.globl vector36
vector36:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $36
80107095:	6a 24                	push   $0x24
  jmp alltraps
80107097:	e9 70 f8 ff ff       	jmp    8010690c <alltraps>

8010709c <vector37>:
.globl vector37
vector37:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $37
8010709e:	6a 25                	push   $0x25
  jmp alltraps
801070a0:	e9 67 f8 ff ff       	jmp    8010690c <alltraps>

801070a5 <vector38>:
.globl vector38
vector38:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $38
801070a7:	6a 26                	push   $0x26
  jmp alltraps
801070a9:	e9 5e f8 ff ff       	jmp    8010690c <alltraps>

801070ae <vector39>:
.globl vector39
vector39:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $39
801070b0:	6a 27                	push   $0x27
  jmp alltraps
801070b2:	e9 55 f8 ff ff       	jmp    8010690c <alltraps>

801070b7 <vector40>:
.globl vector40
vector40:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $40
801070b9:	6a 28                	push   $0x28
  jmp alltraps
801070bb:	e9 4c f8 ff ff       	jmp    8010690c <alltraps>

801070c0 <vector41>:
.globl vector41
vector41:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $41
801070c2:	6a 29                	push   $0x29
  jmp alltraps
801070c4:	e9 43 f8 ff ff       	jmp    8010690c <alltraps>

801070c9 <vector42>:
.globl vector42
vector42:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $42
801070cb:	6a 2a                	push   $0x2a
  jmp alltraps
801070cd:	e9 3a f8 ff ff       	jmp    8010690c <alltraps>

801070d2 <vector43>:
.globl vector43
vector43:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $43
801070d4:	6a 2b                	push   $0x2b
  jmp alltraps
801070d6:	e9 31 f8 ff ff       	jmp    8010690c <alltraps>

801070db <vector44>:
.globl vector44
vector44:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $44
801070dd:	6a 2c                	push   $0x2c
  jmp alltraps
801070df:	e9 28 f8 ff ff       	jmp    8010690c <alltraps>

801070e4 <vector45>:
.globl vector45
vector45:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $45
801070e6:	6a 2d                	push   $0x2d
  jmp alltraps
801070e8:	e9 1f f8 ff ff       	jmp    8010690c <alltraps>

801070ed <vector46>:
.globl vector46
vector46:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $46
801070ef:	6a 2e                	push   $0x2e
  jmp alltraps
801070f1:	e9 16 f8 ff ff       	jmp    8010690c <alltraps>

801070f6 <vector47>:
.globl vector47
vector47:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $47
801070f8:	6a 2f                	push   $0x2f
  jmp alltraps
801070fa:	e9 0d f8 ff ff       	jmp    8010690c <alltraps>

801070ff <vector48>:
.globl vector48
vector48:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $48
80107101:	6a 30                	push   $0x30
  jmp alltraps
80107103:	e9 04 f8 ff ff       	jmp    8010690c <alltraps>

80107108 <vector49>:
.globl vector49
vector49:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $49
8010710a:	6a 31                	push   $0x31
  jmp alltraps
8010710c:	e9 fb f7 ff ff       	jmp    8010690c <alltraps>

80107111 <vector50>:
.globl vector50
vector50:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $50
80107113:	6a 32                	push   $0x32
  jmp alltraps
80107115:	e9 f2 f7 ff ff       	jmp    8010690c <alltraps>

8010711a <vector51>:
.globl vector51
vector51:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $51
8010711c:	6a 33                	push   $0x33
  jmp alltraps
8010711e:	e9 e9 f7 ff ff       	jmp    8010690c <alltraps>

80107123 <vector52>:
.globl vector52
vector52:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $52
80107125:	6a 34                	push   $0x34
  jmp alltraps
80107127:	e9 e0 f7 ff ff       	jmp    8010690c <alltraps>

8010712c <vector53>:
.globl vector53
vector53:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $53
8010712e:	6a 35                	push   $0x35
  jmp alltraps
80107130:	e9 d7 f7 ff ff       	jmp    8010690c <alltraps>

80107135 <vector54>:
.globl vector54
vector54:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $54
80107137:	6a 36                	push   $0x36
  jmp alltraps
80107139:	e9 ce f7 ff ff       	jmp    8010690c <alltraps>

8010713e <vector55>:
.globl vector55
vector55:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $55
80107140:	6a 37                	push   $0x37
  jmp alltraps
80107142:	e9 c5 f7 ff ff       	jmp    8010690c <alltraps>

80107147 <vector56>:
.globl vector56
vector56:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $56
80107149:	6a 38                	push   $0x38
  jmp alltraps
8010714b:	e9 bc f7 ff ff       	jmp    8010690c <alltraps>

80107150 <vector57>:
.globl vector57
vector57:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $57
80107152:	6a 39                	push   $0x39
  jmp alltraps
80107154:	e9 b3 f7 ff ff       	jmp    8010690c <alltraps>

80107159 <vector58>:
.globl vector58
vector58:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $58
8010715b:	6a 3a                	push   $0x3a
  jmp alltraps
8010715d:	e9 aa f7 ff ff       	jmp    8010690c <alltraps>

80107162 <vector59>:
.globl vector59
vector59:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $59
80107164:	6a 3b                	push   $0x3b
  jmp alltraps
80107166:	e9 a1 f7 ff ff       	jmp    8010690c <alltraps>

8010716b <vector60>:
.globl vector60
vector60:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $60
8010716d:	6a 3c                	push   $0x3c
  jmp alltraps
8010716f:	e9 98 f7 ff ff       	jmp    8010690c <alltraps>

80107174 <vector61>:
.globl vector61
vector61:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $61
80107176:	6a 3d                	push   $0x3d
  jmp alltraps
80107178:	e9 8f f7 ff ff       	jmp    8010690c <alltraps>

8010717d <vector62>:
.globl vector62
vector62:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $62
8010717f:	6a 3e                	push   $0x3e
  jmp alltraps
80107181:	e9 86 f7 ff ff       	jmp    8010690c <alltraps>

80107186 <vector63>:
.globl vector63
vector63:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $63
80107188:	6a 3f                	push   $0x3f
  jmp alltraps
8010718a:	e9 7d f7 ff ff       	jmp    8010690c <alltraps>

8010718f <vector64>:
.globl vector64
vector64:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $64
80107191:	6a 40                	push   $0x40
  jmp alltraps
80107193:	e9 74 f7 ff ff       	jmp    8010690c <alltraps>

80107198 <vector65>:
.globl vector65
vector65:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $65
8010719a:	6a 41                	push   $0x41
  jmp alltraps
8010719c:	e9 6b f7 ff ff       	jmp    8010690c <alltraps>

801071a1 <vector66>:
.globl vector66
vector66:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $66
801071a3:	6a 42                	push   $0x42
  jmp alltraps
801071a5:	e9 62 f7 ff ff       	jmp    8010690c <alltraps>

801071aa <vector67>:
.globl vector67
vector67:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $67
801071ac:	6a 43                	push   $0x43
  jmp alltraps
801071ae:	e9 59 f7 ff ff       	jmp    8010690c <alltraps>

801071b3 <vector68>:
.globl vector68
vector68:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $68
801071b5:	6a 44                	push   $0x44
  jmp alltraps
801071b7:	e9 50 f7 ff ff       	jmp    8010690c <alltraps>

801071bc <vector69>:
.globl vector69
vector69:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $69
801071be:	6a 45                	push   $0x45
  jmp alltraps
801071c0:	e9 47 f7 ff ff       	jmp    8010690c <alltraps>

801071c5 <vector70>:
.globl vector70
vector70:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $70
801071c7:	6a 46                	push   $0x46
  jmp alltraps
801071c9:	e9 3e f7 ff ff       	jmp    8010690c <alltraps>

801071ce <vector71>:
.globl vector71
vector71:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $71
801071d0:	6a 47                	push   $0x47
  jmp alltraps
801071d2:	e9 35 f7 ff ff       	jmp    8010690c <alltraps>

801071d7 <vector72>:
.globl vector72
vector72:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $72
801071d9:	6a 48                	push   $0x48
  jmp alltraps
801071db:	e9 2c f7 ff ff       	jmp    8010690c <alltraps>

801071e0 <vector73>:
.globl vector73
vector73:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $73
801071e2:	6a 49                	push   $0x49
  jmp alltraps
801071e4:	e9 23 f7 ff ff       	jmp    8010690c <alltraps>

801071e9 <vector74>:
.globl vector74
vector74:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $74
801071eb:	6a 4a                	push   $0x4a
  jmp alltraps
801071ed:	e9 1a f7 ff ff       	jmp    8010690c <alltraps>

801071f2 <vector75>:
.globl vector75
vector75:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $75
801071f4:	6a 4b                	push   $0x4b
  jmp alltraps
801071f6:	e9 11 f7 ff ff       	jmp    8010690c <alltraps>

801071fb <vector76>:
.globl vector76
vector76:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $76
801071fd:	6a 4c                	push   $0x4c
  jmp alltraps
801071ff:	e9 08 f7 ff ff       	jmp    8010690c <alltraps>

80107204 <vector77>:
.globl vector77
vector77:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $77
80107206:	6a 4d                	push   $0x4d
  jmp alltraps
80107208:	e9 ff f6 ff ff       	jmp    8010690c <alltraps>

8010720d <vector78>:
.globl vector78
vector78:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $78
8010720f:	6a 4e                	push   $0x4e
  jmp alltraps
80107211:	e9 f6 f6 ff ff       	jmp    8010690c <alltraps>

80107216 <vector79>:
.globl vector79
vector79:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $79
80107218:	6a 4f                	push   $0x4f
  jmp alltraps
8010721a:	e9 ed f6 ff ff       	jmp    8010690c <alltraps>

8010721f <vector80>:
.globl vector80
vector80:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $80
80107221:	6a 50                	push   $0x50
  jmp alltraps
80107223:	e9 e4 f6 ff ff       	jmp    8010690c <alltraps>

80107228 <vector81>:
.globl vector81
vector81:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $81
8010722a:	6a 51                	push   $0x51
  jmp alltraps
8010722c:	e9 db f6 ff ff       	jmp    8010690c <alltraps>

80107231 <vector82>:
.globl vector82
vector82:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $82
80107233:	6a 52                	push   $0x52
  jmp alltraps
80107235:	e9 d2 f6 ff ff       	jmp    8010690c <alltraps>

8010723a <vector83>:
.globl vector83
vector83:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $83
8010723c:	6a 53                	push   $0x53
  jmp alltraps
8010723e:	e9 c9 f6 ff ff       	jmp    8010690c <alltraps>

80107243 <vector84>:
.globl vector84
vector84:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $84
80107245:	6a 54                	push   $0x54
  jmp alltraps
80107247:	e9 c0 f6 ff ff       	jmp    8010690c <alltraps>

8010724c <vector85>:
.globl vector85
vector85:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $85
8010724e:	6a 55                	push   $0x55
  jmp alltraps
80107250:	e9 b7 f6 ff ff       	jmp    8010690c <alltraps>

80107255 <vector86>:
.globl vector86
vector86:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $86
80107257:	6a 56                	push   $0x56
  jmp alltraps
80107259:	e9 ae f6 ff ff       	jmp    8010690c <alltraps>

8010725e <vector87>:
.globl vector87
vector87:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $87
80107260:	6a 57                	push   $0x57
  jmp alltraps
80107262:	e9 a5 f6 ff ff       	jmp    8010690c <alltraps>

80107267 <vector88>:
.globl vector88
vector88:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $88
80107269:	6a 58                	push   $0x58
  jmp alltraps
8010726b:	e9 9c f6 ff ff       	jmp    8010690c <alltraps>

80107270 <vector89>:
.globl vector89
vector89:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $89
80107272:	6a 59                	push   $0x59
  jmp alltraps
80107274:	e9 93 f6 ff ff       	jmp    8010690c <alltraps>

80107279 <vector90>:
.globl vector90
vector90:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $90
8010727b:	6a 5a                	push   $0x5a
  jmp alltraps
8010727d:	e9 8a f6 ff ff       	jmp    8010690c <alltraps>

80107282 <vector91>:
.globl vector91
vector91:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $91
80107284:	6a 5b                	push   $0x5b
  jmp alltraps
80107286:	e9 81 f6 ff ff       	jmp    8010690c <alltraps>

8010728b <vector92>:
.globl vector92
vector92:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $92
8010728d:	6a 5c                	push   $0x5c
  jmp alltraps
8010728f:	e9 78 f6 ff ff       	jmp    8010690c <alltraps>

80107294 <vector93>:
.globl vector93
vector93:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $93
80107296:	6a 5d                	push   $0x5d
  jmp alltraps
80107298:	e9 6f f6 ff ff       	jmp    8010690c <alltraps>

8010729d <vector94>:
.globl vector94
vector94:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $94
8010729f:	6a 5e                	push   $0x5e
  jmp alltraps
801072a1:	e9 66 f6 ff ff       	jmp    8010690c <alltraps>

801072a6 <vector95>:
.globl vector95
vector95:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $95
801072a8:	6a 5f                	push   $0x5f
  jmp alltraps
801072aa:	e9 5d f6 ff ff       	jmp    8010690c <alltraps>

801072af <vector96>:
.globl vector96
vector96:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $96
801072b1:	6a 60                	push   $0x60
  jmp alltraps
801072b3:	e9 54 f6 ff ff       	jmp    8010690c <alltraps>

801072b8 <vector97>:
.globl vector97
vector97:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $97
801072ba:	6a 61                	push   $0x61
  jmp alltraps
801072bc:	e9 4b f6 ff ff       	jmp    8010690c <alltraps>

801072c1 <vector98>:
.globl vector98
vector98:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $98
801072c3:	6a 62                	push   $0x62
  jmp alltraps
801072c5:	e9 42 f6 ff ff       	jmp    8010690c <alltraps>

801072ca <vector99>:
.globl vector99
vector99:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $99
801072cc:	6a 63                	push   $0x63
  jmp alltraps
801072ce:	e9 39 f6 ff ff       	jmp    8010690c <alltraps>

801072d3 <vector100>:
.globl vector100
vector100:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $100
801072d5:	6a 64                	push   $0x64
  jmp alltraps
801072d7:	e9 30 f6 ff ff       	jmp    8010690c <alltraps>

801072dc <vector101>:
.globl vector101
vector101:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $101
801072de:	6a 65                	push   $0x65
  jmp alltraps
801072e0:	e9 27 f6 ff ff       	jmp    8010690c <alltraps>

801072e5 <vector102>:
.globl vector102
vector102:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $102
801072e7:	6a 66                	push   $0x66
  jmp alltraps
801072e9:	e9 1e f6 ff ff       	jmp    8010690c <alltraps>

801072ee <vector103>:
.globl vector103
vector103:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $103
801072f0:	6a 67                	push   $0x67
  jmp alltraps
801072f2:	e9 15 f6 ff ff       	jmp    8010690c <alltraps>

801072f7 <vector104>:
.globl vector104
vector104:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $104
801072f9:	6a 68                	push   $0x68
  jmp alltraps
801072fb:	e9 0c f6 ff ff       	jmp    8010690c <alltraps>

80107300 <vector105>:
.globl vector105
vector105:
  pushl $0
80107300:	6a 00                	push   $0x0
  pushl $105
80107302:	6a 69                	push   $0x69
  jmp alltraps
80107304:	e9 03 f6 ff ff       	jmp    8010690c <alltraps>

80107309 <vector106>:
.globl vector106
vector106:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $106
8010730b:	6a 6a                	push   $0x6a
  jmp alltraps
8010730d:	e9 fa f5 ff ff       	jmp    8010690c <alltraps>

80107312 <vector107>:
.globl vector107
vector107:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $107
80107314:	6a 6b                	push   $0x6b
  jmp alltraps
80107316:	e9 f1 f5 ff ff       	jmp    8010690c <alltraps>

8010731b <vector108>:
.globl vector108
vector108:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $108
8010731d:	6a 6c                	push   $0x6c
  jmp alltraps
8010731f:	e9 e8 f5 ff ff       	jmp    8010690c <alltraps>

80107324 <vector109>:
.globl vector109
vector109:
  pushl $0
80107324:	6a 00                	push   $0x0
  pushl $109
80107326:	6a 6d                	push   $0x6d
  jmp alltraps
80107328:	e9 df f5 ff ff       	jmp    8010690c <alltraps>

8010732d <vector110>:
.globl vector110
vector110:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $110
8010732f:	6a 6e                	push   $0x6e
  jmp alltraps
80107331:	e9 d6 f5 ff ff       	jmp    8010690c <alltraps>

80107336 <vector111>:
.globl vector111
vector111:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $111
80107338:	6a 6f                	push   $0x6f
  jmp alltraps
8010733a:	e9 cd f5 ff ff       	jmp    8010690c <alltraps>

8010733f <vector112>:
.globl vector112
vector112:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $112
80107341:	6a 70                	push   $0x70
  jmp alltraps
80107343:	e9 c4 f5 ff ff       	jmp    8010690c <alltraps>

80107348 <vector113>:
.globl vector113
vector113:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $113
8010734a:	6a 71                	push   $0x71
  jmp alltraps
8010734c:	e9 bb f5 ff ff       	jmp    8010690c <alltraps>

80107351 <vector114>:
.globl vector114
vector114:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $114
80107353:	6a 72                	push   $0x72
  jmp alltraps
80107355:	e9 b2 f5 ff ff       	jmp    8010690c <alltraps>

8010735a <vector115>:
.globl vector115
vector115:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $115
8010735c:	6a 73                	push   $0x73
  jmp alltraps
8010735e:	e9 a9 f5 ff ff       	jmp    8010690c <alltraps>

80107363 <vector116>:
.globl vector116
vector116:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $116
80107365:	6a 74                	push   $0x74
  jmp alltraps
80107367:	e9 a0 f5 ff ff       	jmp    8010690c <alltraps>

8010736c <vector117>:
.globl vector117
vector117:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $117
8010736e:	6a 75                	push   $0x75
  jmp alltraps
80107370:	e9 97 f5 ff ff       	jmp    8010690c <alltraps>

80107375 <vector118>:
.globl vector118
vector118:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $118
80107377:	6a 76                	push   $0x76
  jmp alltraps
80107379:	e9 8e f5 ff ff       	jmp    8010690c <alltraps>

8010737e <vector119>:
.globl vector119
vector119:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $119
80107380:	6a 77                	push   $0x77
  jmp alltraps
80107382:	e9 85 f5 ff ff       	jmp    8010690c <alltraps>

80107387 <vector120>:
.globl vector120
vector120:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $120
80107389:	6a 78                	push   $0x78
  jmp alltraps
8010738b:	e9 7c f5 ff ff       	jmp    8010690c <alltraps>

80107390 <vector121>:
.globl vector121
vector121:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $121
80107392:	6a 79                	push   $0x79
  jmp alltraps
80107394:	e9 73 f5 ff ff       	jmp    8010690c <alltraps>

80107399 <vector122>:
.globl vector122
vector122:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $122
8010739b:	6a 7a                	push   $0x7a
  jmp alltraps
8010739d:	e9 6a f5 ff ff       	jmp    8010690c <alltraps>

801073a2 <vector123>:
.globl vector123
vector123:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $123
801073a4:	6a 7b                	push   $0x7b
  jmp alltraps
801073a6:	e9 61 f5 ff ff       	jmp    8010690c <alltraps>

801073ab <vector124>:
.globl vector124
vector124:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $124
801073ad:	6a 7c                	push   $0x7c
  jmp alltraps
801073af:	e9 58 f5 ff ff       	jmp    8010690c <alltraps>

801073b4 <vector125>:
.globl vector125
vector125:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $125
801073b6:	6a 7d                	push   $0x7d
  jmp alltraps
801073b8:	e9 4f f5 ff ff       	jmp    8010690c <alltraps>

801073bd <vector126>:
.globl vector126
vector126:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $126
801073bf:	6a 7e                	push   $0x7e
  jmp alltraps
801073c1:	e9 46 f5 ff ff       	jmp    8010690c <alltraps>

801073c6 <vector127>:
.globl vector127
vector127:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $127
801073c8:	6a 7f                	push   $0x7f
  jmp alltraps
801073ca:	e9 3d f5 ff ff       	jmp    8010690c <alltraps>

801073cf <vector128>:
.globl vector128
vector128:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $128
801073d1:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073d6:	e9 31 f5 ff ff       	jmp    8010690c <alltraps>

801073db <vector129>:
.globl vector129
vector129:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $129
801073dd:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073e2:	e9 25 f5 ff ff       	jmp    8010690c <alltraps>

801073e7 <vector130>:
.globl vector130
vector130:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $130
801073e9:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073ee:	e9 19 f5 ff ff       	jmp    8010690c <alltraps>

801073f3 <vector131>:
.globl vector131
vector131:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $131
801073f5:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073fa:	e9 0d f5 ff ff       	jmp    8010690c <alltraps>

801073ff <vector132>:
.globl vector132
vector132:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $132
80107401:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107406:	e9 01 f5 ff ff       	jmp    8010690c <alltraps>

8010740b <vector133>:
.globl vector133
vector133:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $133
8010740d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107412:	e9 f5 f4 ff ff       	jmp    8010690c <alltraps>

80107417 <vector134>:
.globl vector134
vector134:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $134
80107419:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010741e:	e9 e9 f4 ff ff       	jmp    8010690c <alltraps>

80107423 <vector135>:
.globl vector135
vector135:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $135
80107425:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010742a:	e9 dd f4 ff ff       	jmp    8010690c <alltraps>

8010742f <vector136>:
.globl vector136
vector136:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $136
80107431:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107436:	e9 d1 f4 ff ff       	jmp    8010690c <alltraps>

8010743b <vector137>:
.globl vector137
vector137:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $137
8010743d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107442:	e9 c5 f4 ff ff       	jmp    8010690c <alltraps>

80107447 <vector138>:
.globl vector138
vector138:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $138
80107449:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010744e:	e9 b9 f4 ff ff       	jmp    8010690c <alltraps>

80107453 <vector139>:
.globl vector139
vector139:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $139
80107455:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010745a:	e9 ad f4 ff ff       	jmp    8010690c <alltraps>

8010745f <vector140>:
.globl vector140
vector140:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $140
80107461:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107466:	e9 a1 f4 ff ff       	jmp    8010690c <alltraps>

8010746b <vector141>:
.globl vector141
vector141:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $141
8010746d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107472:	e9 95 f4 ff ff       	jmp    8010690c <alltraps>

80107477 <vector142>:
.globl vector142
vector142:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $142
80107479:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010747e:	e9 89 f4 ff ff       	jmp    8010690c <alltraps>

80107483 <vector143>:
.globl vector143
vector143:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $143
80107485:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010748a:	e9 7d f4 ff ff       	jmp    8010690c <alltraps>

8010748f <vector144>:
.globl vector144
vector144:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $144
80107491:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107496:	e9 71 f4 ff ff       	jmp    8010690c <alltraps>

8010749b <vector145>:
.globl vector145
vector145:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $145
8010749d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074a2:	e9 65 f4 ff ff       	jmp    8010690c <alltraps>

801074a7 <vector146>:
.globl vector146
vector146:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $146
801074a9:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074ae:	e9 59 f4 ff ff       	jmp    8010690c <alltraps>

801074b3 <vector147>:
.globl vector147
vector147:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $147
801074b5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074ba:	e9 4d f4 ff ff       	jmp    8010690c <alltraps>

801074bf <vector148>:
.globl vector148
vector148:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $148
801074c1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074c6:	e9 41 f4 ff ff       	jmp    8010690c <alltraps>

801074cb <vector149>:
.globl vector149
vector149:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $149
801074cd:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074d2:	e9 35 f4 ff ff       	jmp    8010690c <alltraps>

801074d7 <vector150>:
.globl vector150
vector150:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $150
801074d9:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074de:	e9 29 f4 ff ff       	jmp    8010690c <alltraps>

801074e3 <vector151>:
.globl vector151
vector151:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $151
801074e5:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074ea:	e9 1d f4 ff ff       	jmp    8010690c <alltraps>

801074ef <vector152>:
.globl vector152
vector152:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $152
801074f1:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074f6:	e9 11 f4 ff ff       	jmp    8010690c <alltraps>

801074fb <vector153>:
.globl vector153
vector153:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $153
801074fd:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107502:	e9 05 f4 ff ff       	jmp    8010690c <alltraps>

80107507 <vector154>:
.globl vector154
vector154:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $154
80107509:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010750e:	e9 f9 f3 ff ff       	jmp    8010690c <alltraps>

80107513 <vector155>:
.globl vector155
vector155:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $155
80107515:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010751a:	e9 ed f3 ff ff       	jmp    8010690c <alltraps>

8010751f <vector156>:
.globl vector156
vector156:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $156
80107521:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107526:	e9 e1 f3 ff ff       	jmp    8010690c <alltraps>

8010752b <vector157>:
.globl vector157
vector157:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $157
8010752d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107532:	e9 d5 f3 ff ff       	jmp    8010690c <alltraps>

80107537 <vector158>:
.globl vector158
vector158:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $158
80107539:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010753e:	e9 c9 f3 ff ff       	jmp    8010690c <alltraps>

80107543 <vector159>:
.globl vector159
vector159:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $159
80107545:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010754a:	e9 bd f3 ff ff       	jmp    8010690c <alltraps>

8010754f <vector160>:
.globl vector160
vector160:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $160
80107551:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107556:	e9 b1 f3 ff ff       	jmp    8010690c <alltraps>

8010755b <vector161>:
.globl vector161
vector161:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $161
8010755d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107562:	e9 a5 f3 ff ff       	jmp    8010690c <alltraps>

80107567 <vector162>:
.globl vector162
vector162:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $162
80107569:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010756e:	e9 99 f3 ff ff       	jmp    8010690c <alltraps>

80107573 <vector163>:
.globl vector163
vector163:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $163
80107575:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010757a:	e9 8d f3 ff ff       	jmp    8010690c <alltraps>

8010757f <vector164>:
.globl vector164
vector164:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $164
80107581:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107586:	e9 81 f3 ff ff       	jmp    8010690c <alltraps>

8010758b <vector165>:
.globl vector165
vector165:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $165
8010758d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107592:	e9 75 f3 ff ff       	jmp    8010690c <alltraps>

80107597 <vector166>:
.globl vector166
vector166:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $166
80107599:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010759e:	e9 69 f3 ff ff       	jmp    8010690c <alltraps>

801075a3 <vector167>:
.globl vector167
vector167:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $167
801075a5:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075aa:	e9 5d f3 ff ff       	jmp    8010690c <alltraps>

801075af <vector168>:
.globl vector168
vector168:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $168
801075b1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075b6:	e9 51 f3 ff ff       	jmp    8010690c <alltraps>

801075bb <vector169>:
.globl vector169
vector169:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $169
801075bd:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075c2:	e9 45 f3 ff ff       	jmp    8010690c <alltraps>

801075c7 <vector170>:
.globl vector170
vector170:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $170
801075c9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075ce:	e9 39 f3 ff ff       	jmp    8010690c <alltraps>

801075d3 <vector171>:
.globl vector171
vector171:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $171
801075d5:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075da:	e9 2d f3 ff ff       	jmp    8010690c <alltraps>

801075df <vector172>:
.globl vector172
vector172:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $172
801075e1:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075e6:	e9 21 f3 ff ff       	jmp    8010690c <alltraps>

801075eb <vector173>:
.globl vector173
vector173:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $173
801075ed:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075f2:	e9 15 f3 ff ff       	jmp    8010690c <alltraps>

801075f7 <vector174>:
.globl vector174
vector174:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $174
801075f9:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075fe:	e9 09 f3 ff ff       	jmp    8010690c <alltraps>

80107603 <vector175>:
.globl vector175
vector175:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $175
80107605:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010760a:	e9 fd f2 ff ff       	jmp    8010690c <alltraps>

8010760f <vector176>:
.globl vector176
vector176:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $176
80107611:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107616:	e9 f1 f2 ff ff       	jmp    8010690c <alltraps>

8010761b <vector177>:
.globl vector177
vector177:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $177
8010761d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107622:	e9 e5 f2 ff ff       	jmp    8010690c <alltraps>

80107627 <vector178>:
.globl vector178
vector178:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $178
80107629:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010762e:	e9 d9 f2 ff ff       	jmp    8010690c <alltraps>

80107633 <vector179>:
.globl vector179
vector179:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $179
80107635:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010763a:	e9 cd f2 ff ff       	jmp    8010690c <alltraps>

8010763f <vector180>:
.globl vector180
vector180:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $180
80107641:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107646:	e9 c1 f2 ff ff       	jmp    8010690c <alltraps>

8010764b <vector181>:
.globl vector181
vector181:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $181
8010764d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107652:	e9 b5 f2 ff ff       	jmp    8010690c <alltraps>

80107657 <vector182>:
.globl vector182
vector182:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $182
80107659:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010765e:	e9 a9 f2 ff ff       	jmp    8010690c <alltraps>

80107663 <vector183>:
.globl vector183
vector183:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $183
80107665:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010766a:	e9 9d f2 ff ff       	jmp    8010690c <alltraps>

8010766f <vector184>:
.globl vector184
vector184:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $184
80107671:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107676:	e9 91 f2 ff ff       	jmp    8010690c <alltraps>

8010767b <vector185>:
.globl vector185
vector185:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $185
8010767d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107682:	e9 85 f2 ff ff       	jmp    8010690c <alltraps>

80107687 <vector186>:
.globl vector186
vector186:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $186
80107689:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010768e:	e9 79 f2 ff ff       	jmp    8010690c <alltraps>

80107693 <vector187>:
.globl vector187
vector187:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $187
80107695:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010769a:	e9 6d f2 ff ff       	jmp    8010690c <alltraps>

8010769f <vector188>:
.globl vector188
vector188:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $188
801076a1:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076a6:	e9 61 f2 ff ff       	jmp    8010690c <alltraps>

801076ab <vector189>:
.globl vector189
vector189:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $189
801076ad:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076b2:	e9 55 f2 ff ff       	jmp    8010690c <alltraps>

801076b7 <vector190>:
.globl vector190
vector190:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $190
801076b9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076be:	e9 49 f2 ff ff       	jmp    8010690c <alltraps>

801076c3 <vector191>:
.globl vector191
vector191:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $191
801076c5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076ca:	e9 3d f2 ff ff       	jmp    8010690c <alltraps>

801076cf <vector192>:
.globl vector192
vector192:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $192
801076d1:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076d6:	e9 31 f2 ff ff       	jmp    8010690c <alltraps>

801076db <vector193>:
.globl vector193
vector193:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $193
801076dd:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076e2:	e9 25 f2 ff ff       	jmp    8010690c <alltraps>

801076e7 <vector194>:
.globl vector194
vector194:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $194
801076e9:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076ee:	e9 19 f2 ff ff       	jmp    8010690c <alltraps>

801076f3 <vector195>:
.globl vector195
vector195:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $195
801076f5:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076fa:	e9 0d f2 ff ff       	jmp    8010690c <alltraps>

801076ff <vector196>:
.globl vector196
vector196:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $196
80107701:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107706:	e9 01 f2 ff ff       	jmp    8010690c <alltraps>

8010770b <vector197>:
.globl vector197
vector197:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $197
8010770d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107712:	e9 f5 f1 ff ff       	jmp    8010690c <alltraps>

80107717 <vector198>:
.globl vector198
vector198:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $198
80107719:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010771e:	e9 e9 f1 ff ff       	jmp    8010690c <alltraps>

80107723 <vector199>:
.globl vector199
vector199:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $199
80107725:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010772a:	e9 dd f1 ff ff       	jmp    8010690c <alltraps>

8010772f <vector200>:
.globl vector200
vector200:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $200
80107731:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107736:	e9 d1 f1 ff ff       	jmp    8010690c <alltraps>

8010773b <vector201>:
.globl vector201
vector201:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $201
8010773d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107742:	e9 c5 f1 ff ff       	jmp    8010690c <alltraps>

80107747 <vector202>:
.globl vector202
vector202:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $202
80107749:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010774e:	e9 b9 f1 ff ff       	jmp    8010690c <alltraps>

80107753 <vector203>:
.globl vector203
vector203:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $203
80107755:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010775a:	e9 ad f1 ff ff       	jmp    8010690c <alltraps>

8010775f <vector204>:
.globl vector204
vector204:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $204
80107761:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107766:	e9 a1 f1 ff ff       	jmp    8010690c <alltraps>

8010776b <vector205>:
.globl vector205
vector205:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $205
8010776d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107772:	e9 95 f1 ff ff       	jmp    8010690c <alltraps>

80107777 <vector206>:
.globl vector206
vector206:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $206
80107779:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010777e:	e9 89 f1 ff ff       	jmp    8010690c <alltraps>

80107783 <vector207>:
.globl vector207
vector207:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $207
80107785:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010778a:	e9 7d f1 ff ff       	jmp    8010690c <alltraps>

8010778f <vector208>:
.globl vector208
vector208:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $208
80107791:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107796:	e9 71 f1 ff ff       	jmp    8010690c <alltraps>

8010779b <vector209>:
.globl vector209
vector209:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $209
8010779d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077a2:	e9 65 f1 ff ff       	jmp    8010690c <alltraps>

801077a7 <vector210>:
.globl vector210
vector210:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $210
801077a9:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077ae:	e9 59 f1 ff ff       	jmp    8010690c <alltraps>

801077b3 <vector211>:
.globl vector211
vector211:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $211
801077b5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077ba:	e9 4d f1 ff ff       	jmp    8010690c <alltraps>

801077bf <vector212>:
.globl vector212
vector212:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $212
801077c1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077c6:	e9 41 f1 ff ff       	jmp    8010690c <alltraps>

801077cb <vector213>:
.globl vector213
vector213:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $213
801077cd:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077d2:	e9 35 f1 ff ff       	jmp    8010690c <alltraps>

801077d7 <vector214>:
.globl vector214
vector214:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $214
801077d9:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077de:	e9 29 f1 ff ff       	jmp    8010690c <alltraps>

801077e3 <vector215>:
.globl vector215
vector215:
  pushl $0
801077e3:	6a 00                	push   $0x0
  pushl $215
801077e5:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077ea:	e9 1d f1 ff ff       	jmp    8010690c <alltraps>

801077ef <vector216>:
.globl vector216
vector216:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $216
801077f1:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077f6:	e9 11 f1 ff ff       	jmp    8010690c <alltraps>

801077fb <vector217>:
.globl vector217
vector217:
  pushl $0
801077fb:	6a 00                	push   $0x0
  pushl $217
801077fd:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107802:	e9 05 f1 ff ff       	jmp    8010690c <alltraps>

80107807 <vector218>:
.globl vector218
vector218:
  pushl $0
80107807:	6a 00                	push   $0x0
  pushl $218
80107809:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010780e:	e9 f9 f0 ff ff       	jmp    8010690c <alltraps>

80107813 <vector219>:
.globl vector219
vector219:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $219
80107815:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010781a:	e9 ed f0 ff ff       	jmp    8010690c <alltraps>

8010781f <vector220>:
.globl vector220
vector220:
  pushl $0
8010781f:	6a 00                	push   $0x0
  pushl $220
80107821:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107826:	e9 e1 f0 ff ff       	jmp    8010690c <alltraps>

8010782b <vector221>:
.globl vector221
vector221:
  pushl $0
8010782b:	6a 00                	push   $0x0
  pushl $221
8010782d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107832:	e9 d5 f0 ff ff       	jmp    8010690c <alltraps>

80107837 <vector222>:
.globl vector222
vector222:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $222
80107839:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010783e:	e9 c9 f0 ff ff       	jmp    8010690c <alltraps>

80107843 <vector223>:
.globl vector223
vector223:
  pushl $0
80107843:	6a 00                	push   $0x0
  pushl $223
80107845:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010784a:	e9 bd f0 ff ff       	jmp    8010690c <alltraps>

8010784f <vector224>:
.globl vector224
vector224:
  pushl $0
8010784f:	6a 00                	push   $0x0
  pushl $224
80107851:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107856:	e9 b1 f0 ff ff       	jmp    8010690c <alltraps>

8010785b <vector225>:
.globl vector225
vector225:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $225
8010785d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107862:	e9 a5 f0 ff ff       	jmp    8010690c <alltraps>

80107867 <vector226>:
.globl vector226
vector226:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $226
80107869:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010786e:	e9 99 f0 ff ff       	jmp    8010690c <alltraps>

80107873 <vector227>:
.globl vector227
vector227:
  pushl $0
80107873:	6a 00                	push   $0x0
  pushl $227
80107875:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010787a:	e9 8d f0 ff ff       	jmp    8010690c <alltraps>

8010787f <vector228>:
.globl vector228
vector228:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $228
80107881:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107886:	e9 81 f0 ff ff       	jmp    8010690c <alltraps>

8010788b <vector229>:
.globl vector229
vector229:
  pushl $0
8010788b:	6a 00                	push   $0x0
  pushl $229
8010788d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107892:	e9 75 f0 ff ff       	jmp    8010690c <alltraps>

80107897 <vector230>:
.globl vector230
vector230:
  pushl $0
80107897:	6a 00                	push   $0x0
  pushl $230
80107899:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010789e:	e9 69 f0 ff ff       	jmp    8010690c <alltraps>

801078a3 <vector231>:
.globl vector231
vector231:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $231
801078a5:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078aa:	e9 5d f0 ff ff       	jmp    8010690c <alltraps>

801078af <vector232>:
.globl vector232
vector232:
  pushl $0
801078af:	6a 00                	push   $0x0
  pushl $232
801078b1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078b6:	e9 51 f0 ff ff       	jmp    8010690c <alltraps>

801078bb <vector233>:
.globl vector233
vector233:
  pushl $0
801078bb:	6a 00                	push   $0x0
  pushl $233
801078bd:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078c2:	e9 45 f0 ff ff       	jmp    8010690c <alltraps>

801078c7 <vector234>:
.globl vector234
vector234:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $234
801078c9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078ce:	e9 39 f0 ff ff       	jmp    8010690c <alltraps>

801078d3 <vector235>:
.globl vector235
vector235:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $235
801078d5:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078da:	e9 2d f0 ff ff       	jmp    8010690c <alltraps>

801078df <vector236>:
.globl vector236
vector236:
  pushl $0
801078df:	6a 00                	push   $0x0
  pushl $236
801078e1:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078e6:	e9 21 f0 ff ff       	jmp    8010690c <alltraps>

801078eb <vector237>:
.globl vector237
vector237:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $237
801078ed:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078f2:	e9 15 f0 ff ff       	jmp    8010690c <alltraps>

801078f7 <vector238>:
.globl vector238
vector238:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $238
801078f9:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078fe:	e9 09 f0 ff ff       	jmp    8010690c <alltraps>

80107903 <vector239>:
.globl vector239
vector239:
  pushl $0
80107903:	6a 00                	push   $0x0
  pushl $239
80107905:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010790a:	e9 fd ef ff ff       	jmp    8010690c <alltraps>

8010790f <vector240>:
.globl vector240
vector240:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $240
80107911:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107916:	e9 f1 ef ff ff       	jmp    8010690c <alltraps>

8010791b <vector241>:
.globl vector241
vector241:
  pushl $0
8010791b:	6a 00                	push   $0x0
  pushl $241
8010791d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107922:	e9 e5 ef ff ff       	jmp    8010690c <alltraps>

80107927 <vector242>:
.globl vector242
vector242:
  pushl $0
80107927:	6a 00                	push   $0x0
  pushl $242
80107929:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010792e:	e9 d9 ef ff ff       	jmp    8010690c <alltraps>

80107933 <vector243>:
.globl vector243
vector243:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $243
80107935:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010793a:	e9 cd ef ff ff       	jmp    8010690c <alltraps>

8010793f <vector244>:
.globl vector244
vector244:
  pushl $0
8010793f:	6a 00                	push   $0x0
  pushl $244
80107941:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107946:	e9 c1 ef ff ff       	jmp    8010690c <alltraps>

8010794b <vector245>:
.globl vector245
vector245:
  pushl $0
8010794b:	6a 00                	push   $0x0
  pushl $245
8010794d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107952:	e9 b5 ef ff ff       	jmp    8010690c <alltraps>

80107957 <vector246>:
.globl vector246
vector246:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $246
80107959:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010795e:	e9 a9 ef ff ff       	jmp    8010690c <alltraps>

80107963 <vector247>:
.globl vector247
vector247:
  pushl $0
80107963:	6a 00                	push   $0x0
  pushl $247
80107965:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010796a:	e9 9d ef ff ff       	jmp    8010690c <alltraps>

8010796f <vector248>:
.globl vector248
vector248:
  pushl $0
8010796f:	6a 00                	push   $0x0
  pushl $248
80107971:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107976:	e9 91 ef ff ff       	jmp    8010690c <alltraps>

8010797b <vector249>:
.globl vector249
vector249:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $249
8010797d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107982:	e9 85 ef ff ff       	jmp    8010690c <alltraps>

80107987 <vector250>:
.globl vector250
vector250:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $250
80107989:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010798e:	e9 79 ef ff ff       	jmp    8010690c <alltraps>

80107993 <vector251>:
.globl vector251
vector251:
  pushl $0
80107993:	6a 00                	push   $0x0
  pushl $251
80107995:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010799a:	e9 6d ef ff ff       	jmp    8010690c <alltraps>

8010799f <vector252>:
.globl vector252
vector252:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $252
801079a1:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079a6:	e9 61 ef ff ff       	jmp    8010690c <alltraps>

801079ab <vector253>:
.globl vector253
vector253:
  pushl $0
801079ab:	6a 00                	push   $0x0
  pushl $253
801079ad:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079b2:	e9 55 ef ff ff       	jmp    8010690c <alltraps>

801079b7 <vector254>:
.globl vector254
vector254:
  pushl $0
801079b7:	6a 00                	push   $0x0
  pushl $254
801079b9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079be:	e9 49 ef ff ff       	jmp    8010690c <alltraps>

801079c3 <vector255>:
.globl vector255
vector255:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $255
801079c5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079ca:	e9 3d ef ff ff       	jmp    8010690c <alltraps>

801079cf <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079cf:	55                   	push   %ebp
801079d0:	89 e5                	mov    %esp,%ebp
801079d2:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801079d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801079d8:	83 e8 01             	sub    $0x1,%eax
801079db:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079df:	8b 45 08             	mov    0x8(%ebp),%eax
801079e2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079e6:	8b 45 08             	mov    0x8(%ebp),%eax
801079e9:	c1 e8 10             	shr    $0x10,%eax
801079ec:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801079f0:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079f3:	0f 01 10             	lgdtl  (%eax)
}
801079f6:	90                   	nop
801079f7:	c9                   	leave  
801079f8:	c3                   	ret    

801079f9 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801079f9:	55                   	push   %ebp
801079fa:	89 e5                	mov    %esp,%ebp
801079fc:	83 ec 04             	sub    $0x4,%esp
801079ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107a02:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a06:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a0a:	0f 00 d8             	ltr    %ax
}
80107a0d:	90                   	nop
80107a0e:	c9                   	leave  
80107a0f:	c3                   	ret    

80107a10 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a10:	55                   	push   %ebp
80107a11:	89 e5                	mov    %esp,%ebp
80107a13:	83 ec 04             	sub    $0x4,%esp
80107a16:	8b 45 08             	mov    0x8(%ebp),%eax
80107a19:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a1d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a21:	8e e8                	mov    %eax,%gs
}
80107a23:	90                   	nop
80107a24:	c9                   	leave  
80107a25:	c3                   	ret    

80107a26 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a26:	55                   	push   %ebp
80107a27:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a29:	8b 45 08             	mov    0x8(%ebp),%eax
80107a2c:	0f 22 d8             	mov    %eax,%cr3
}
80107a2f:	90                   	nop
80107a30:	5d                   	pop    %ebp
80107a31:	c3                   	ret    

80107a32 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a32:	55                   	push   %ebp
80107a33:	89 e5                	mov    %esp,%ebp
80107a35:	8b 45 08             	mov    0x8(%ebp),%eax
80107a38:	05 00 00 00 80       	add    $0x80000000,%eax
80107a3d:	5d                   	pop    %ebp
80107a3e:	c3                   	ret    

80107a3f <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a3f:	55                   	push   %ebp
80107a40:	89 e5                	mov    %esp,%ebp
80107a42:	8b 45 08             	mov    0x8(%ebp),%eax
80107a45:	05 00 00 00 80       	add    $0x80000000,%eax
80107a4a:	5d                   	pop    %ebp
80107a4b:	c3                   	ret    

80107a4c <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a4c:	55                   	push   %ebp
80107a4d:	89 e5                	mov    %esp,%ebp
80107a4f:	53                   	push   %ebx
80107a50:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a53:	e8 74 b5 ff ff       	call   80102fcc <cpunum>
80107a58:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a5e:	05 60 23 11 80       	add    $0x80112360,%eax
80107a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a69:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a82:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a86:	83 e2 f0             	and    $0xfffffff0,%edx
80107a89:	83 ca 0a             	or     $0xa,%edx
80107a8c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a92:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a96:	83 ca 10             	or     $0x10,%edx
80107a99:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aa3:	83 e2 9f             	and    $0xffffff9f,%edx
80107aa6:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aac:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ab0:	83 ca 80             	or     $0xffffff80,%edx
80107ab3:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107abd:	83 ca 0f             	or     $0xf,%edx
80107ac0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107aca:	83 e2 ef             	and    $0xffffffef,%edx
80107acd:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ad7:	83 e2 df             	and    $0xffffffdf,%edx
80107ada:	88 50 7e             	mov    %dl,0x7e(%eax)
80107add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ae4:	83 ca 40             	or     $0x40,%edx
80107ae7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aed:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107af1:	83 ca 80             	or     $0xffffff80,%edx
80107af4:	88 50 7e             	mov    %dl,0x7e(%eax)
80107af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afa:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b08:	ff ff 
80107b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0d:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b14:	00 00 
80107b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b19:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b23:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b2a:	83 e2 f0             	and    $0xfffffff0,%edx
80107b2d:	83 ca 02             	or     $0x2,%edx
80107b30:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b40:	83 ca 10             	or     $0x10,%edx
80107b43:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b53:	83 e2 9f             	and    $0xffffff9f,%edx
80107b56:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b66:	83 ca 80             	or     $0xffffff80,%edx
80107b69:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b72:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b79:	83 ca 0f             	or     $0xf,%edx
80107b7c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b85:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b8c:	83 e2 ef             	and    $0xffffffef,%edx
80107b8f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b98:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b9f:	83 e2 df             	and    $0xffffffdf,%edx
80107ba2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bab:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bb2:	83 ca 40             	or     $0x40,%edx
80107bb5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbe:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bc5:	83 ca 80             	or     $0xffffff80,%edx
80107bc8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd1:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdb:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107be2:	ff ff 
80107be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be7:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bee:	00 00 
80107bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf3:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c04:	83 e2 f0             	and    $0xfffffff0,%edx
80107c07:	83 ca 0a             	or     $0xa,%edx
80107c0a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c1a:	83 ca 10             	or     $0x10,%edx
80107c1d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c2d:	83 ca 60             	or     $0x60,%edx
80107c30:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c39:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c40:	83 ca 80             	or     $0xffffff80,%edx
80107c43:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c53:	83 ca 0f             	or     $0xf,%edx
80107c56:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c66:	83 e2 ef             	and    $0xffffffef,%edx
80107c69:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c72:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c79:	83 e2 df             	and    $0xffffffdf,%edx
80107c7c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c85:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c8c:	83 ca 40             	or     $0x40,%edx
80107c8f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c98:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c9f:	83 ca 80             	or     $0xffffff80,%edx
80107ca2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cab:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb5:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107cbc:	ff ff 
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107cc8:	00 00 
80107cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccd:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cde:	83 e2 f0             	and    $0xfffffff0,%edx
80107ce1:	83 ca 02             	or     $0x2,%edx
80107ce4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ced:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cf4:	83 ca 10             	or     $0x10,%edx
80107cf7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d00:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d07:	83 ca 60             	or     $0x60,%edx
80107d0a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d13:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d1a:	83 ca 80             	or     $0xffffff80,%edx
80107d1d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d26:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d2d:	83 ca 0f             	or     $0xf,%edx
80107d30:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d39:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d40:	83 e2 ef             	and    $0xffffffef,%edx
80107d43:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d53:	83 e2 df             	and    $0xffffffdf,%edx
80107d56:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d66:	83 ca 40             	or     $0x40,%edx
80107d69:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d72:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d79:	83 ca 80             	or     $0xffffff80,%edx
80107d7c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d85:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8f:	05 b4 00 00 00       	add    $0xb4,%eax
80107d94:	89 c3                	mov    %eax,%ebx
80107d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d99:	05 b4 00 00 00       	add    $0xb4,%eax
80107d9e:	c1 e8 10             	shr    $0x10,%eax
80107da1:	89 c2                	mov    %eax,%edx
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	05 b4 00 00 00       	add    $0xb4,%eax
80107dab:	c1 e8 18             	shr    $0x18,%eax
80107dae:	89 c1                	mov    %eax,%ecx
80107db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db3:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107dba:	00 00 
80107dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbf:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dd9:	83 e2 f0             	and    $0xfffffff0,%edx
80107ddc:	83 ca 02             	or     $0x2,%edx
80107ddf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107def:	83 ca 10             	or     $0x10,%edx
80107df2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e02:	83 e2 9f             	and    $0xffffff9f,%edx
80107e05:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e15:	83 ca 80             	or     $0xffffff80,%edx
80107e18:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e21:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e28:	83 e2 f0             	and    $0xfffffff0,%edx
80107e2b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e3b:	83 e2 ef             	and    $0xffffffef,%edx
80107e3e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e47:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e4e:	83 e2 df             	and    $0xffffffdf,%edx
80107e51:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e61:	83 ca 40             	or     $0x40,%edx
80107e64:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e74:	83 ca 80             	or     $0xffffff80,%edx
80107e77:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e89:	83 c0 70             	add    $0x70,%eax
80107e8c:	83 ec 08             	sub    $0x8,%esp
80107e8f:	6a 38                	push   $0x38
80107e91:	50                   	push   %eax
80107e92:	e8 38 fb ff ff       	call   801079cf <lgdt>
80107e97:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107e9a:	83 ec 0c             	sub    $0xc,%esp
80107e9d:	6a 18                	push   $0x18
80107e9f:	e8 6c fb ff ff       	call   80107a10 <loadgs>
80107ea4:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaa:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107eb0:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107eb7:	00 00 00 00 
}
80107ebb:	90                   	nop
80107ebc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ebf:	c9                   	leave  
80107ec0:	c3                   	ret    

80107ec1 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107ec1:	55                   	push   %ebp
80107ec2:	89 e5                	mov    %esp,%ebp
80107ec4:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eca:	c1 e8 16             	shr    $0x16,%eax
80107ecd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed7:	01 d0                	add    %edx,%eax
80107ed9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107edf:	8b 00                	mov    (%eax),%eax
80107ee1:	83 e0 01             	and    $0x1,%eax
80107ee4:	85 c0                	test   %eax,%eax
80107ee6:	74 18                	je     80107f00 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eeb:	8b 00                	mov    (%eax),%eax
80107eed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef2:	50                   	push   %eax
80107ef3:	e8 47 fb ff ff       	call   80107a3f <p2v>
80107ef8:	83 c4 04             	add    $0x4,%esp
80107efb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107efe:	eb 48                	jmp    80107f48 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f04:	74 0e                	je     80107f14 <walkpgdir+0x53>
80107f06:	e8 5b ad ff ff       	call   80102c66 <kalloc>
80107f0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f12:	75 07                	jne    80107f1b <walkpgdir+0x5a>
      return 0;
80107f14:	b8 00 00 00 00       	mov    $0x0,%eax
80107f19:	eb 44                	jmp    80107f5f <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f1b:	83 ec 04             	sub    $0x4,%esp
80107f1e:	68 00 10 00 00       	push   $0x1000
80107f23:	6a 00                	push   $0x0
80107f25:	ff 75 f4             	pushl  -0xc(%ebp)
80107f28:	e8 25 d6 ff ff       	call   80105552 <memset>
80107f2d:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f30:	83 ec 0c             	sub    $0xc,%esp
80107f33:	ff 75 f4             	pushl  -0xc(%ebp)
80107f36:	e8 f7 fa ff ff       	call   80107a32 <v2p>
80107f3b:	83 c4 10             	add    $0x10,%esp
80107f3e:	83 c8 07             	or     $0x7,%eax
80107f41:	89 c2                	mov    %eax,%edx
80107f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f46:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f4b:	c1 e8 0c             	shr    $0xc,%eax
80107f4e:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f53:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5d:	01 d0                	add    %edx,%eax
}
80107f5f:	c9                   	leave  
80107f60:	c3                   	ret    

80107f61 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f61:	55                   	push   %ebp
80107f62:	89 e5                	mov    %esp,%ebp
80107f64:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f67:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f72:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f75:	8b 45 10             	mov    0x10(%ebp),%eax
80107f78:	01 d0                	add    %edx,%eax
80107f7a:	83 e8 01             	sub    $0x1,%eax
80107f7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f85:	83 ec 04             	sub    $0x4,%esp
80107f88:	6a 01                	push   $0x1
80107f8a:	ff 75 f4             	pushl  -0xc(%ebp)
80107f8d:	ff 75 08             	pushl  0x8(%ebp)
80107f90:	e8 2c ff ff ff       	call   80107ec1 <walkpgdir>
80107f95:	83 c4 10             	add    $0x10,%esp
80107f98:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f9f:	75 07                	jne    80107fa8 <mappages+0x47>
      return -1;
80107fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fa6:	eb 47                	jmp    80107fef <mappages+0x8e>
    if(*pte & PTE_P)
80107fa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fab:	8b 00                	mov    (%eax),%eax
80107fad:	83 e0 01             	and    $0x1,%eax
80107fb0:	85 c0                	test   %eax,%eax
80107fb2:	74 0d                	je     80107fc1 <mappages+0x60>
      panic("remap");
80107fb4:	83 ec 0c             	sub    $0xc,%esp
80107fb7:	68 48 8e 10 80       	push   $0x80108e48
80107fbc:	e8 a5 85 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80107fc1:	8b 45 18             	mov    0x18(%ebp),%eax
80107fc4:	0b 45 14             	or     0x14(%ebp),%eax
80107fc7:	83 c8 01             	or     $0x1,%eax
80107fca:	89 c2                	mov    %eax,%edx
80107fcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fcf:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fd7:	74 10                	je     80107fe9 <mappages+0x88>
      break;
    a += PGSIZE;
80107fd9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107fe0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107fe7:	eb 9c                	jmp    80107f85 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107fe9:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107fea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fef:	c9                   	leave  
80107ff0:	c3                   	ret    

80107ff1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ff1:	55                   	push   %ebp
80107ff2:	89 e5                	mov    %esp,%ebp
80107ff4:	53                   	push   %ebx
80107ff5:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ff8:	e8 69 ac ff ff       	call   80102c66 <kalloc>
80107ffd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108000:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108004:	75 0a                	jne    80108010 <setupkvm+0x1f>
    return 0;
80108006:	b8 00 00 00 00       	mov    $0x0,%eax
8010800b:	e9 8e 00 00 00       	jmp    8010809e <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108010:	83 ec 04             	sub    $0x4,%esp
80108013:	68 00 10 00 00       	push   $0x1000
80108018:	6a 00                	push   $0x0
8010801a:	ff 75 f0             	pushl  -0x10(%ebp)
8010801d:	e8 30 d5 ff ff       	call   80105552 <memset>
80108022:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108025:	83 ec 0c             	sub    $0xc,%esp
80108028:	68 00 00 00 0e       	push   $0xe000000
8010802d:	e8 0d fa ff ff       	call   80107a3f <p2v>
80108032:	83 c4 10             	add    $0x10,%esp
80108035:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010803a:	76 0d                	jbe    80108049 <setupkvm+0x58>
    panic("PHYSTOP too high");
8010803c:	83 ec 0c             	sub    $0xc,%esp
8010803f:	68 4e 8e 10 80       	push   $0x80108e4e
80108044:	e8 1d 85 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108049:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80108050:	eb 40                	jmp    80108092 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108055:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805b:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010805e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108061:	8b 58 08             	mov    0x8(%eax),%ebx
80108064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108067:	8b 40 04             	mov    0x4(%eax),%eax
8010806a:	29 c3                	sub    %eax,%ebx
8010806c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806f:	8b 00                	mov    (%eax),%eax
80108071:	83 ec 0c             	sub    $0xc,%esp
80108074:	51                   	push   %ecx
80108075:	52                   	push   %edx
80108076:	53                   	push   %ebx
80108077:	50                   	push   %eax
80108078:	ff 75 f0             	pushl  -0x10(%ebp)
8010807b:	e8 e1 fe ff ff       	call   80107f61 <mappages>
80108080:	83 c4 20             	add    $0x20,%esp
80108083:	85 c0                	test   %eax,%eax
80108085:	79 07                	jns    8010808e <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108087:	b8 00 00 00 00       	mov    $0x0,%eax
8010808c:	eb 10                	jmp    8010809e <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010808e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108092:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80108099:	72 b7                	jb     80108052 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010809b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010809e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080a1:	c9                   	leave  
801080a2:	c3                   	ret    

801080a3 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080a3:	55                   	push   %ebp
801080a4:	89 e5                	mov    %esp,%ebp
801080a6:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080a9:	e8 43 ff ff ff       	call   80107ff1 <setupkvm>
801080ae:	a3 38 56 11 80       	mov    %eax,0x80115638
  switchkvm();
801080b3:	e8 03 00 00 00       	call   801080bb <switchkvm>
}
801080b8:	90                   	nop
801080b9:	c9                   	leave  
801080ba:	c3                   	ret    

801080bb <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080bb:	55                   	push   %ebp
801080bc:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801080be:	a1 38 56 11 80       	mov    0x80115638,%eax
801080c3:	50                   	push   %eax
801080c4:	e8 69 f9 ff ff       	call   80107a32 <v2p>
801080c9:	83 c4 04             	add    $0x4,%esp
801080cc:	50                   	push   %eax
801080cd:	e8 54 f9 ff ff       	call   80107a26 <lcr3>
801080d2:	83 c4 04             	add    $0x4,%esp
}
801080d5:	90                   	nop
801080d6:	c9                   	leave  
801080d7:	c3                   	ret    

801080d8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080d8:	55                   	push   %ebp
801080d9:	89 e5                	mov    %esp,%ebp
801080db:	56                   	push   %esi
801080dc:	53                   	push   %ebx
  pushcli();
801080dd:	e8 6a d3 ff ff       	call   8010544c <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801080e2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080e8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080ef:	83 c2 08             	add    $0x8,%edx
801080f2:	89 d6                	mov    %edx,%esi
801080f4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080fb:	83 c2 08             	add    $0x8,%edx
801080fe:	c1 ea 10             	shr    $0x10,%edx
80108101:	89 d3                	mov    %edx,%ebx
80108103:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010810a:	83 c2 08             	add    $0x8,%edx
8010810d:	c1 ea 18             	shr    $0x18,%edx
80108110:	89 d1                	mov    %edx,%ecx
80108112:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108119:	67 00 
8010811b:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108122:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108128:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010812f:	83 e2 f0             	and    $0xfffffff0,%edx
80108132:	83 ca 09             	or     $0x9,%edx
80108135:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010813b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108142:	83 ca 10             	or     $0x10,%edx
80108145:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010814b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108152:	83 e2 9f             	and    $0xffffff9f,%edx
80108155:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010815b:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108162:	83 ca 80             	or     $0xffffff80,%edx
80108165:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010816b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108172:	83 e2 f0             	and    $0xfffffff0,%edx
80108175:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010817b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108182:	83 e2 ef             	and    $0xffffffef,%edx
80108185:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010818b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108192:	83 e2 df             	and    $0xffffffdf,%edx
80108195:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010819b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801081a2:	83 ca 40             	or     $0x40,%edx
801081a5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801081ab:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801081b2:	83 e2 7f             	and    $0x7f,%edx
801081b5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801081bb:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801081c1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081c7:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801081ce:	83 e2 ef             	and    $0xffffffef,%edx
801081d1:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801081d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081dd:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801081e3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081e9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801081f0:	8b 52 08             	mov    0x8(%edx),%edx
801081f3:	81 c2 00 10 00 00    	add    $0x1000,%edx
801081f9:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801081fc:	83 ec 0c             	sub    $0xc,%esp
801081ff:	6a 30                	push   $0x30
80108201:	e8 f3 f7 ff ff       	call   801079f9 <ltr>
80108206:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108209:	8b 45 08             	mov    0x8(%ebp),%eax
8010820c:	8b 40 04             	mov    0x4(%eax),%eax
8010820f:	85 c0                	test   %eax,%eax
80108211:	75 0d                	jne    80108220 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108213:	83 ec 0c             	sub    $0xc,%esp
80108216:	68 5f 8e 10 80       	push   $0x80108e5f
8010821b:	e8 46 83 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108220:	8b 45 08             	mov    0x8(%ebp),%eax
80108223:	8b 40 04             	mov    0x4(%eax),%eax
80108226:	83 ec 0c             	sub    $0xc,%esp
80108229:	50                   	push   %eax
8010822a:	e8 03 f8 ff ff       	call   80107a32 <v2p>
8010822f:	83 c4 10             	add    $0x10,%esp
80108232:	83 ec 0c             	sub    $0xc,%esp
80108235:	50                   	push   %eax
80108236:	e8 eb f7 ff ff       	call   80107a26 <lcr3>
8010823b:	83 c4 10             	add    $0x10,%esp
  popcli();
8010823e:	e8 4e d2 ff ff       	call   80105491 <popcli>
}
80108243:	90                   	nop
80108244:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108247:	5b                   	pop    %ebx
80108248:	5e                   	pop    %esi
80108249:	5d                   	pop    %ebp
8010824a:	c3                   	ret    

8010824b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010824b:	55                   	push   %ebp
8010824c:	89 e5                	mov    %esp,%ebp
8010824e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108251:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108258:	76 0d                	jbe    80108267 <inituvm+0x1c>
    panic("inituvm: more than a page");
8010825a:	83 ec 0c             	sub    $0xc,%esp
8010825d:	68 73 8e 10 80       	push   $0x80108e73
80108262:	e8 ff 82 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108267:	e8 fa a9 ff ff       	call   80102c66 <kalloc>
8010826c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010826f:	83 ec 04             	sub    $0x4,%esp
80108272:	68 00 10 00 00       	push   $0x1000
80108277:	6a 00                	push   $0x0
80108279:	ff 75 f4             	pushl  -0xc(%ebp)
8010827c:	e8 d1 d2 ff ff       	call   80105552 <memset>
80108281:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108284:	83 ec 0c             	sub    $0xc,%esp
80108287:	ff 75 f4             	pushl  -0xc(%ebp)
8010828a:	e8 a3 f7 ff ff       	call   80107a32 <v2p>
8010828f:	83 c4 10             	add    $0x10,%esp
80108292:	83 ec 0c             	sub    $0xc,%esp
80108295:	6a 06                	push   $0x6
80108297:	50                   	push   %eax
80108298:	68 00 10 00 00       	push   $0x1000
8010829d:	6a 00                	push   $0x0
8010829f:	ff 75 08             	pushl  0x8(%ebp)
801082a2:	e8 ba fc ff ff       	call   80107f61 <mappages>
801082a7:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801082aa:	83 ec 04             	sub    $0x4,%esp
801082ad:	ff 75 10             	pushl  0x10(%ebp)
801082b0:	ff 75 0c             	pushl  0xc(%ebp)
801082b3:	ff 75 f4             	pushl  -0xc(%ebp)
801082b6:	e8 56 d3 ff ff       	call   80105611 <memmove>
801082bb:	83 c4 10             	add    $0x10,%esp
}
801082be:	90                   	nop
801082bf:	c9                   	leave  
801082c0:	c3                   	ret    

801082c1 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082c1:	55                   	push   %ebp
801082c2:	89 e5                	mov    %esp,%ebp
801082c4:	53                   	push   %ebx
801082c5:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801082cb:	25 ff 0f 00 00       	and    $0xfff,%eax
801082d0:	85 c0                	test   %eax,%eax
801082d2:	74 0d                	je     801082e1 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801082d4:	83 ec 0c             	sub    $0xc,%esp
801082d7:	68 90 8e 10 80       	push   $0x80108e90
801082dc:	e8 85 82 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082e8:	e9 95 00 00 00       	jmp    80108382 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801082ed:	8b 55 0c             	mov    0xc(%ebp),%edx
801082f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f3:	01 d0                	add    %edx,%eax
801082f5:	83 ec 04             	sub    $0x4,%esp
801082f8:	6a 00                	push   $0x0
801082fa:	50                   	push   %eax
801082fb:	ff 75 08             	pushl  0x8(%ebp)
801082fe:	e8 be fb ff ff       	call   80107ec1 <walkpgdir>
80108303:	83 c4 10             	add    $0x10,%esp
80108306:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108309:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010830d:	75 0d                	jne    8010831c <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010830f:	83 ec 0c             	sub    $0xc,%esp
80108312:	68 b3 8e 10 80       	push   $0x80108eb3
80108317:	e8 4a 82 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010831c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010831f:	8b 00                	mov    (%eax),%eax
80108321:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108326:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108329:	8b 45 18             	mov    0x18(%ebp),%eax
8010832c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010832f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108334:	77 0b                	ja     80108341 <loaduvm+0x80>
      n = sz - i;
80108336:	8b 45 18             	mov    0x18(%ebp),%eax
80108339:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010833c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010833f:	eb 07                	jmp    80108348 <loaduvm+0x87>
    else
      n = PGSIZE;
80108341:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108348:	8b 55 14             	mov    0x14(%ebp),%edx
8010834b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108351:	83 ec 0c             	sub    $0xc,%esp
80108354:	ff 75 e8             	pushl  -0x18(%ebp)
80108357:	e8 e3 f6 ff ff       	call   80107a3f <p2v>
8010835c:	83 c4 10             	add    $0x10,%esp
8010835f:	ff 75 f0             	pushl  -0x10(%ebp)
80108362:	53                   	push   %ebx
80108363:	50                   	push   %eax
80108364:	ff 75 10             	pushl  0x10(%ebp)
80108367:	e8 6c 9b ff ff       	call   80101ed8 <readi>
8010836c:	83 c4 10             	add    $0x10,%esp
8010836f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108372:	74 07                	je     8010837b <loaduvm+0xba>
      return -1;
80108374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108379:	eb 18                	jmp    80108393 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010837b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108385:	3b 45 18             	cmp    0x18(%ebp),%eax
80108388:	0f 82 5f ff ff ff    	jb     801082ed <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010838e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108396:	c9                   	leave  
80108397:	c3                   	ret    

80108398 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108398:	55                   	push   %ebp
80108399:	89 e5                	mov    %esp,%ebp
8010839b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010839e:	8b 45 10             	mov    0x10(%ebp),%eax
801083a1:	85 c0                	test   %eax,%eax
801083a3:	79 0a                	jns    801083af <allocuvm+0x17>
    return 0;
801083a5:	b8 00 00 00 00       	mov    $0x0,%eax
801083aa:	e9 b0 00 00 00       	jmp    8010845f <allocuvm+0xc7>
  if(newsz < oldsz)
801083af:	8b 45 10             	mov    0x10(%ebp),%eax
801083b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083b5:	73 08                	jae    801083bf <allocuvm+0x27>
    return oldsz;
801083b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801083ba:	e9 a0 00 00 00       	jmp    8010845f <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
801083bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c2:	05 ff 0f 00 00       	add    $0xfff,%eax
801083c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801083cf:	eb 7f                	jmp    80108450 <allocuvm+0xb8>
    mem = kalloc();
801083d1:	e8 90 a8 ff ff       	call   80102c66 <kalloc>
801083d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801083d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083dd:	75 2b                	jne    8010840a <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801083df:	83 ec 0c             	sub    $0xc,%esp
801083e2:	68 d1 8e 10 80       	push   $0x80108ed1
801083e7:	e8 da 7f ff ff       	call   801003c6 <cprintf>
801083ec:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801083ef:	83 ec 04             	sub    $0x4,%esp
801083f2:	ff 75 0c             	pushl  0xc(%ebp)
801083f5:	ff 75 10             	pushl  0x10(%ebp)
801083f8:	ff 75 08             	pushl  0x8(%ebp)
801083fb:	e8 61 00 00 00       	call   80108461 <deallocuvm>
80108400:	83 c4 10             	add    $0x10,%esp
      return 0;
80108403:	b8 00 00 00 00       	mov    $0x0,%eax
80108408:	eb 55                	jmp    8010845f <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
8010840a:	83 ec 04             	sub    $0x4,%esp
8010840d:	68 00 10 00 00       	push   $0x1000
80108412:	6a 00                	push   $0x0
80108414:	ff 75 f0             	pushl  -0x10(%ebp)
80108417:	e8 36 d1 ff ff       	call   80105552 <memset>
8010841c:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010841f:	83 ec 0c             	sub    $0xc,%esp
80108422:	ff 75 f0             	pushl  -0x10(%ebp)
80108425:	e8 08 f6 ff ff       	call   80107a32 <v2p>
8010842a:	83 c4 10             	add    $0x10,%esp
8010842d:	89 c2                	mov    %eax,%edx
8010842f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108432:	83 ec 0c             	sub    $0xc,%esp
80108435:	6a 06                	push   $0x6
80108437:	52                   	push   %edx
80108438:	68 00 10 00 00       	push   $0x1000
8010843d:	50                   	push   %eax
8010843e:	ff 75 08             	pushl  0x8(%ebp)
80108441:	e8 1b fb ff ff       	call   80107f61 <mappages>
80108446:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108449:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108453:	3b 45 10             	cmp    0x10(%ebp),%eax
80108456:	0f 82 75 ff ff ff    	jb     801083d1 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010845c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010845f:	c9                   	leave  
80108460:	c3                   	ret    

80108461 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108461:	55                   	push   %ebp
80108462:	89 e5                	mov    %esp,%ebp
80108464:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108467:	8b 45 10             	mov    0x10(%ebp),%eax
8010846a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010846d:	72 08                	jb     80108477 <deallocuvm+0x16>
    return oldsz;
8010846f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108472:	e9 a5 00 00 00       	jmp    8010851c <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108477:	8b 45 10             	mov    0x10(%ebp),%eax
8010847a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010847f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108484:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108487:	e9 81 00 00 00       	jmp    8010850d <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010848c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848f:	83 ec 04             	sub    $0x4,%esp
80108492:	6a 00                	push   $0x0
80108494:	50                   	push   %eax
80108495:	ff 75 08             	pushl  0x8(%ebp)
80108498:	e8 24 fa ff ff       	call   80107ec1 <walkpgdir>
8010849d:	83 c4 10             	add    $0x10,%esp
801084a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801084a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084a7:	75 09                	jne    801084b2 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
801084a9:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801084b0:	eb 54                	jmp    80108506 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801084b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b5:	8b 00                	mov    (%eax),%eax
801084b7:	83 e0 01             	and    $0x1,%eax
801084ba:	85 c0                	test   %eax,%eax
801084bc:	74 48                	je     80108506 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
801084be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c1:	8b 00                	mov    (%eax),%eax
801084c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801084cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084cf:	75 0d                	jne    801084de <deallocuvm+0x7d>
        panic("kfree");
801084d1:	83 ec 0c             	sub    $0xc,%esp
801084d4:	68 e9 8e 10 80       	push   $0x80108ee9
801084d9:	e8 88 80 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801084de:	83 ec 0c             	sub    $0xc,%esp
801084e1:	ff 75 ec             	pushl  -0x14(%ebp)
801084e4:	e8 56 f5 ff ff       	call   80107a3f <p2v>
801084e9:	83 c4 10             	add    $0x10,%esp
801084ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801084ef:	83 ec 0c             	sub    $0xc,%esp
801084f2:	ff 75 e8             	pushl  -0x18(%ebp)
801084f5:	e8 cf a6 ff ff       	call   80102bc9 <kfree>
801084fa:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801084fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108500:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108506:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010850d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108510:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108513:	0f 82 73 ff ff ff    	jb     8010848c <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108519:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010851c:	c9                   	leave  
8010851d:	c3                   	ret    

8010851e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010851e:	55                   	push   %ebp
8010851f:	89 e5                	mov    %esp,%ebp
80108521:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108524:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108528:	75 0d                	jne    80108537 <freevm+0x19>
    panic("freevm: no pgdir");
8010852a:	83 ec 0c             	sub    $0xc,%esp
8010852d:	68 ef 8e 10 80       	push   $0x80108eef
80108532:	e8 2f 80 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108537:	83 ec 04             	sub    $0x4,%esp
8010853a:	6a 00                	push   $0x0
8010853c:	68 00 00 00 80       	push   $0x80000000
80108541:	ff 75 08             	pushl  0x8(%ebp)
80108544:	e8 18 ff ff ff       	call   80108461 <deallocuvm>
80108549:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010854c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108553:	eb 4f                	jmp    801085a4 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108558:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010855f:	8b 45 08             	mov    0x8(%ebp),%eax
80108562:	01 d0                	add    %edx,%eax
80108564:	8b 00                	mov    (%eax),%eax
80108566:	83 e0 01             	and    $0x1,%eax
80108569:	85 c0                	test   %eax,%eax
8010856b:	74 33                	je     801085a0 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010856d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108570:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108577:	8b 45 08             	mov    0x8(%ebp),%eax
8010857a:	01 d0                	add    %edx,%eax
8010857c:	8b 00                	mov    (%eax),%eax
8010857e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108583:	83 ec 0c             	sub    $0xc,%esp
80108586:	50                   	push   %eax
80108587:	e8 b3 f4 ff ff       	call   80107a3f <p2v>
8010858c:	83 c4 10             	add    $0x10,%esp
8010858f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108592:	83 ec 0c             	sub    $0xc,%esp
80108595:	ff 75 f0             	pushl  -0x10(%ebp)
80108598:	e8 2c a6 ff ff       	call   80102bc9 <kfree>
8010859d:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801085a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085a4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085ab:	76 a8                	jbe    80108555 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801085ad:	83 ec 0c             	sub    $0xc,%esp
801085b0:	ff 75 08             	pushl  0x8(%ebp)
801085b3:	e8 11 a6 ff ff       	call   80102bc9 <kfree>
801085b8:	83 c4 10             	add    $0x10,%esp
}
801085bb:	90                   	nop
801085bc:	c9                   	leave  
801085bd:	c3                   	ret    

801085be <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801085be:	55                   	push   %ebp
801085bf:	89 e5                	mov    %esp,%ebp
801085c1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085c4:	83 ec 04             	sub    $0x4,%esp
801085c7:	6a 00                	push   $0x0
801085c9:	ff 75 0c             	pushl  0xc(%ebp)
801085cc:	ff 75 08             	pushl  0x8(%ebp)
801085cf:	e8 ed f8 ff ff       	call   80107ec1 <walkpgdir>
801085d4:	83 c4 10             	add    $0x10,%esp
801085d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801085da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801085de:	75 0d                	jne    801085ed <clearpteu+0x2f>
    panic("clearpteu");
801085e0:	83 ec 0c             	sub    $0xc,%esp
801085e3:	68 00 8f 10 80       	push   $0x80108f00
801085e8:	e8 79 7f ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801085ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f0:	8b 00                	mov    (%eax),%eax
801085f2:	83 e0 fb             	and    $0xfffffffb,%eax
801085f5:	89 c2                	mov    %eax,%edx
801085f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fa:	89 10                	mov    %edx,(%eax)
}
801085fc:	90                   	nop
801085fd:	c9                   	leave  
801085fe:	c3                   	ret    

801085ff <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801085ff:	55                   	push   %ebp
80108600:	89 e5                	mov    %esp,%ebp
80108602:	53                   	push   %ebx
80108603:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108606:	e8 e6 f9 ff ff       	call   80107ff1 <setupkvm>
8010860b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010860e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108612:	75 0a                	jne    8010861e <copyuvm+0x1f>
    return 0;
80108614:	b8 00 00 00 00       	mov    $0x0,%eax
80108619:	e9 f8 00 00 00       	jmp    80108716 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010861e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108625:	e9 c4 00 00 00       	jmp    801086ee <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010862a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862d:	83 ec 04             	sub    $0x4,%esp
80108630:	6a 00                	push   $0x0
80108632:	50                   	push   %eax
80108633:	ff 75 08             	pushl  0x8(%ebp)
80108636:	e8 86 f8 ff ff       	call   80107ec1 <walkpgdir>
8010863b:	83 c4 10             	add    $0x10,%esp
8010863e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108641:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108645:	75 0d                	jne    80108654 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108647:	83 ec 0c             	sub    $0xc,%esp
8010864a:	68 0a 8f 10 80       	push   $0x80108f0a
8010864f:	e8 12 7f ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80108654:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108657:	8b 00                	mov    (%eax),%eax
80108659:	83 e0 01             	and    $0x1,%eax
8010865c:	85 c0                	test   %eax,%eax
8010865e:	75 0d                	jne    8010866d <copyuvm+0x6e>
      panic("copyuvm: page not present");
80108660:	83 ec 0c             	sub    $0xc,%esp
80108663:	68 24 8f 10 80       	push   $0x80108f24
80108668:	e8 f9 7e ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010866d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108670:	8b 00                	mov    (%eax),%eax
80108672:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108677:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010867a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010867d:	8b 00                	mov    (%eax),%eax
8010867f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108684:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108687:	e8 da a5 ff ff       	call   80102c66 <kalloc>
8010868c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010868f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108693:	74 6a                	je     801086ff <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108695:	83 ec 0c             	sub    $0xc,%esp
80108698:	ff 75 e8             	pushl  -0x18(%ebp)
8010869b:	e8 9f f3 ff ff       	call   80107a3f <p2v>
801086a0:	83 c4 10             	add    $0x10,%esp
801086a3:	83 ec 04             	sub    $0x4,%esp
801086a6:	68 00 10 00 00       	push   $0x1000
801086ab:	50                   	push   %eax
801086ac:	ff 75 e0             	pushl  -0x20(%ebp)
801086af:	e8 5d cf ff ff       	call   80105611 <memmove>
801086b4:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801086b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801086ba:	83 ec 0c             	sub    $0xc,%esp
801086bd:	ff 75 e0             	pushl  -0x20(%ebp)
801086c0:	e8 6d f3 ff ff       	call   80107a32 <v2p>
801086c5:	83 c4 10             	add    $0x10,%esp
801086c8:	89 c2                	mov    %eax,%edx
801086ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cd:	83 ec 0c             	sub    $0xc,%esp
801086d0:	53                   	push   %ebx
801086d1:	52                   	push   %edx
801086d2:	68 00 10 00 00       	push   $0x1000
801086d7:	50                   	push   %eax
801086d8:	ff 75 f0             	pushl  -0x10(%ebp)
801086db:	e8 81 f8 ff ff       	call   80107f61 <mappages>
801086e0:	83 c4 20             	add    $0x20,%esp
801086e3:	85 c0                	test   %eax,%eax
801086e5:	78 1b                	js     80108702 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801086e7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086f4:	0f 82 30 ff ff ff    	jb     8010862a <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801086fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086fd:	eb 17                	jmp    80108716 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801086ff:	90                   	nop
80108700:	eb 01                	jmp    80108703 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108702:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108703:	83 ec 0c             	sub    $0xc,%esp
80108706:	ff 75 f0             	pushl  -0x10(%ebp)
80108709:	e8 10 fe ff ff       	call   8010851e <freevm>
8010870e:	83 c4 10             	add    $0x10,%esp
  return 0;
80108711:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108716:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108719:	c9                   	leave  
8010871a:	c3                   	ret    

8010871b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010871b:	55                   	push   %ebp
8010871c:	89 e5                	mov    %esp,%ebp
8010871e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108721:	83 ec 04             	sub    $0x4,%esp
80108724:	6a 00                	push   $0x0
80108726:	ff 75 0c             	pushl  0xc(%ebp)
80108729:	ff 75 08             	pushl  0x8(%ebp)
8010872c:	e8 90 f7 ff ff       	call   80107ec1 <walkpgdir>
80108731:	83 c4 10             	add    $0x10,%esp
80108734:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873a:	8b 00                	mov    (%eax),%eax
8010873c:	83 e0 01             	and    $0x1,%eax
8010873f:	85 c0                	test   %eax,%eax
80108741:	75 07                	jne    8010874a <uva2ka+0x2f>
    return 0;
80108743:	b8 00 00 00 00       	mov    $0x0,%eax
80108748:	eb 29                	jmp    80108773 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010874a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874d:	8b 00                	mov    (%eax),%eax
8010874f:	83 e0 04             	and    $0x4,%eax
80108752:	85 c0                	test   %eax,%eax
80108754:	75 07                	jne    8010875d <uva2ka+0x42>
    return 0;
80108756:	b8 00 00 00 00       	mov    $0x0,%eax
8010875b:	eb 16                	jmp    80108773 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010875d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108760:	8b 00                	mov    (%eax),%eax
80108762:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108767:	83 ec 0c             	sub    $0xc,%esp
8010876a:	50                   	push   %eax
8010876b:	e8 cf f2 ff ff       	call   80107a3f <p2v>
80108770:	83 c4 10             	add    $0x10,%esp
}
80108773:	c9                   	leave  
80108774:	c3                   	ret    

80108775 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108775:	55                   	push   %ebp
80108776:	89 e5                	mov    %esp,%ebp
80108778:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010877b:	8b 45 10             	mov    0x10(%ebp),%eax
8010877e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108781:	eb 7f                	jmp    80108802 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108783:	8b 45 0c             	mov    0xc(%ebp),%eax
80108786:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010878b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010878e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108791:	83 ec 08             	sub    $0x8,%esp
80108794:	50                   	push   %eax
80108795:	ff 75 08             	pushl  0x8(%ebp)
80108798:	e8 7e ff ff ff       	call   8010871b <uva2ka>
8010879d:	83 c4 10             	add    $0x10,%esp
801087a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801087a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087a7:	75 07                	jne    801087b0 <copyout+0x3b>
      return -1;
801087a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087ae:	eb 61                	jmp    80108811 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801087b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b3:	2b 45 0c             	sub    0xc(%ebp),%eax
801087b6:	05 00 10 00 00       	add    $0x1000,%eax
801087bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801087be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087c1:	3b 45 14             	cmp    0x14(%ebp),%eax
801087c4:	76 06                	jbe    801087cc <copyout+0x57>
      n = len;
801087c6:	8b 45 14             	mov    0x14(%ebp),%eax
801087c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801087cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801087cf:	2b 45 ec             	sub    -0x14(%ebp),%eax
801087d2:	89 c2                	mov    %eax,%edx
801087d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087d7:	01 d0                	add    %edx,%eax
801087d9:	83 ec 04             	sub    $0x4,%esp
801087dc:	ff 75 f0             	pushl  -0x10(%ebp)
801087df:	ff 75 f4             	pushl  -0xc(%ebp)
801087e2:	50                   	push   %eax
801087e3:	e8 29 ce ff ff       	call   80105611 <memmove>
801087e8:	83 c4 10             	add    $0x10,%esp
    len -= n;
801087eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ee:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801087f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801087f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fa:	05 00 10 00 00       	add    $0x1000,%eax
801087ff:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108802:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108806:	0f 85 77 ff ff ff    	jne    80108783 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010880c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108811:	c9                   	leave  
80108812:	c3                   	ret    

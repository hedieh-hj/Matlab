 A=imread('pic.jpg');
 B=imread('sec.jpg');

 A1=bitand(A,254);
 B1=bitand(B,128);
 B2=B1/128;

 result=A1+B2;
 figure,imshow(result)

%  see secret

result2=bitand(result,1);
result3=result2*128;
figure,imshow(result3)

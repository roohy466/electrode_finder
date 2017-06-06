function show_random_girl
% girl bikoni loader
% first site:  http://www.fanpop.com/clubs/girls/photos/n      n=1:88
% second to click on a pic find    width="25%">  <a href=""
% third code to sreach is and load       onclick="javascript:launchPizap('http
n=randi(88);
filex = ['http://www.fanpop.com/clubs/girls/photos/' num2str(n)];
fullList = urlread(filex);
m=strfind(fullList,'<img class="border" src="http://');
for i=1:size(m,2);
    tmp=fullList(m(i)+25:m(i)+500);
    mm=strfind(tmp,'href="');
    mm2=strfind(tmp(mm+7:end),'">');
    address_click{i}=tmp(mm+7:mm+5+mm2(1));
end
% loading all images
n_rand=randi(size(m,2));
add_rand=['http://www.fanpop.com/'  address_click{n_rand}];
fullList2 = urlread(add_rand);
m=strfind(fullList2,'onclick="javascript:launchPizap(');
tmp_2=fullList2(m(1)+33:m(1)+400);
mm=strfind(tmp_2,'.jpg');
add_final=tmp_2(1:mm+3);
im_url=imread(add_final);
imshow(im_url);
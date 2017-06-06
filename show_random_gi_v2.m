function  show_random_girl_v2(address)
% girl bikoni loader
data_list=load([address '/html/data_list.mat']);
n=randi(size(data_list.url_list,2));
add_final=data_list.url_list{n};
im_url=imread(add_final);
%imwrite(im_url,['image_' num2str(n) '_' num2str(n_rand) '.jpg']);
[x,y]=size(im_url);
if y>1200
    B = imresize(im_url,1/ (y/1200));
elseif x>700
    B = imresize(im_url,1/ (x/700));
else
    B=im_url;
end
imshow((B));


FROM nginx:alpine
ARG PORT
COPY . /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD nginx -g 'daemon off;'
#sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf &&

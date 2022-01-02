FROM openjdk:8-jdk
EXPOSE 3000:3000
RUN mkdir /app
COPY ./build/install/io.gzmo.weatherserver/ /app/
WORKDIR /app/bin
CMD ["./io.gzmo.weatherserver"]

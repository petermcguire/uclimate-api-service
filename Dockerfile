FROM openjdk:8-jdk
EXPOSE 3000:3000
RUN mkdir /app
COPY ./build/install/io.gzmo.weatherserver/ /app/
WORKDIR /app/bin
ENV JAVA_TOOL_OPTIONS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005
CMD ["./io.gzmo.weatherserver"]

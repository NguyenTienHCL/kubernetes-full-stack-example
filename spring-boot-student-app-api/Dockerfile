FROM openjdk:8-jdk-alpine
ARG JAR_FILE
ADD target/${JAR_FILE} /usr/share/myservice/student-app-api-0.0.1-SNAPSHOT.jar
ENTRYPOINT ["/usr/bin/java", "-jar", "/usr/share/myservice/student-app-api-0.0.1-SNAPSHOT.jar"]
ADD target/student-app-api-0.0.1-SNAPSHOT.jar  /usr/share/myservice/lib
EXPOSE 8080

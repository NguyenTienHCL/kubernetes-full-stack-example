FROM openjdk:8-jdk-alpine
COPY target/student-app-api-0.0.1-SNAPSHOT.jar /usr/share/myservice/lib
ARG JAR_FILE
COPY ${JAR_FILE} /usr/share/myservice/student-app-api-0.0.1-SNAPSHOT.jar
ENTRYPOINT ["/usr/bin/java", "-jar", "/usr/share/myservice/student-app-api-0.0.1-SNAPSHOT.jar"]
EXPOSE 8080

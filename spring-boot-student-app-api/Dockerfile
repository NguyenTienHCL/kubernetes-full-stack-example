FROM openjdk:8-jdk-alpine
ARG JAR_FILE
ADD ${JAR_FILE} /usr/share/myservice/student-app-api-0.0.1-SNAPSHOT.jar
ADD /usr/share/myservice/student-app-api-0.0.1-SNAPSHOT.jar /usr/share/myservice/lib
CMD ["/usr/bin/java", "-jar", "/usr/share/myservice/student-app-api-0.0.1-SNAPSHOT.jar"]
EXPOSE 8080

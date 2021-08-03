# syntax=docker/dockerfile:1.2-labs

FROM maven:latest as base

WORKDIR /app

COPY pom.xml settings.xml ./
RUN mvn -s settings.xml dependency:go-offline
COPY src src

FROM base as test
RUN mvn test

FROM base as development
CMD ["mvn", "spring-boot:run", "-Dspring-boot.run.profiles=mysql", \ 
    "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000'"]

FROM test as build
RUN mvn package

FROM openjdk:11-jre-slim as production
COPY --from=build /app/target/spring-petclinic-*.jar /spring-petclinic.jar
EXPOSE 8080

CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/spring-petclinic.jar"]
# syntax=docker/dockerfile:1.2

FROM maven:3-openjdk-16-slim as base

WORKDIR /app

COPY pom.xml ./
RUN mvn dependency:go-offline
COPY src ./src

FROM base as test
RUN ["mvn", "test"]

FROM base as development
CMD ["mvn", "spring-boot:run", "-Dspring-boot.run.profiles=mysql", "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000'"]

FROM base as build
RUN mvn package

FROM openjdk:11-jre-slim as production
EXPOSE 8080

COPY --from=build /app/target/spring-petclinic-*.jar /spring-petclinic.jar

CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/spring-petclinic.jar"]
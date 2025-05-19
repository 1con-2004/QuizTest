FROM maven:3.9-amazoncorretto-17 AS build
WORKDIR /app

# 首先只复制 pom.xml 并下载依赖，这样当代码变更时，依赖缓存不会失效
COPY pom.xml .
RUN mvn dependency:go-offline

# 然后复制源代码并进行构建
COPY src ./src
RUN mvn package -DskipTests

FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 3000
ENTRYPOINT ["java", "-jar", "app.jar"] 
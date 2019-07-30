import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

class ConvertRedirects {
    private static Pattern locationPattern = Pattern.compile(".*?meta http-equiv.*?url=(?<url>.+?)\".*?");

    public static void main(String[] args) throws IOException {
        Stream<Path> walk = Files.walk(Path.of("./public"));
        walk.filter(Files::isRegularFile)
                .filter(path -> path.endsWith("index.html"))
                .map(ConvertRedirects::getRedirectLocations)
                .flatMap(Collection::stream)
                .map(redirect -> String.format("rewrite ^%s/$ %s %s;", redirect.from, redirect.to, redirect.flag))
                .forEach(System.out::println);
    }

    private static List<Redirect> getRedirectLocations(Path path) {
        try {
            String document = Files.readString(path);
            Matcher match = locationPattern.matcher(document);
            if (!match.matches()) {
                return Collections.emptyList();
            }
            URL url = new URL(match.group("url"));
            return List.of(new Redirect(path.getParent().toString().replace("./public", ""), url.getPath()));
        } catch (Exception e) {
            throw new RuntimeException("Failed to produce redirect location for file " + path, e);
        }
    }

    private static class Redirect {
        final String from;
        final String to;
        final String flag;

        Redirect(String from, String to) {
            this.from = from;
            this.to = to;
            flag = from.startsWith("/ref/") ? "redirect" : "permanent";
        }
    }

}
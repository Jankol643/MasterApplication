import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.Scanner;

public class TextInBlocks {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        // Read file path from user
        System.out.print("Enter input file path: ");
        String inputFilePath = scanner.nextLine().trim();

        // Read output file path from user
        System.out.print("Enter output file path: ");
        String outputFilePath = scanner.nextLine().trim();

        // Read line length
        System.out.print("Enter desired line length: ");
        int lineLength = scanner.nextInt();
        scanner.nextLine(); // consume newline

        // Options for cleaning
        System.out.print("Remove empty lines? (yes/no): ");
        boolean removeEmptyLines = scanner.nextLine().trim().equalsIgnoreCase("yes");

        System.out.print("Trim whitespace on each line? (yes/no): ");
        boolean trimWhitespace = scanner.nextLine().trim().equalsIgnoreCase("yes");

        scanner.close();

        // Measure execution time
        long startTime = System.currentTimeMillis();

        try (BufferedReader reader = Files.newBufferedReader(Path.of(inputFilePath));
                BufferedWriter writer = Files.newBufferedWriter(
                        Path.of(outputFilePath),
                        StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING)) {

            String line;
            StringBuilder buffer = new StringBuilder();

            while ((line = reader.readLine()) != null) {
                if (removeEmptyLines && line.trim().isEmpty()) {
                    continue;
                }
                if (trimWhitespace) {
                    line = line.trim();
                }
                buffer.append(line);
            }

            String content = buffer.toString();
            int length = content.length();

            // Output in blocks of x characters
            for (int i = 0; i < length; i += lineLength) {
                int end = Math.min(i + lineLength, length);
                String segment = content.substring(i, end);
                writer.write(segment);
                writer.newLine(); // optional: add newline after each block
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        long endTime = System.currentTimeMillis();
        System.out.println("Processing completed in " + (endTime - startTime) + " ms");
    }
}
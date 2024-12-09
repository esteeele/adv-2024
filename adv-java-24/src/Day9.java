import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class Day9 {

    public void solveDay9() {
        String fileInput = readFileToString();
        List<String> pristineBigBoy = makeBigBoy(fileInput);
        List<String> dirtyBigBoy = new ArrayList<>(pristineBigBoy);

        // we've built megalist now re-arrange
        int leftPointer = 0;
        int rightPointer = dirtyBigBoy.size() - 1;
        while (leftPointer < rightPointer) {
            String leftValue = dirtyBigBoy.get(leftPointer);
            String rightValue = dirtyBigBoy.get(rightPointer);

            if (leftValue.equals(".") && !rightValue.equals(".")) {
                dirtyBigBoy.set(leftPointer, rightValue);
                dirtyBigBoy.set(rightPointer, ".");
                leftPointer++;
                rightPointer--;
            } else {
                if (leftValue.equals(".")) {
                    while (dirtyBigBoy.get(rightPointer).equals(".")) {
                        rightPointer--;
                    }
                } else {
                    leftPointer++;
                }
            }
        }
        long res = calcResult(dirtyBigBoy);
        System.out.println(res);

        List<String> wholeFiles = part2(pristineBigBoy);
        long res_2 = calcResult(wholeFiles);
        System.out.println(wholeFiles);
        System.out.println(res_2);
    }

    private static List<String> makeBigBoy(String fileInput) {
        List<String> bigBoy = new ArrayList<>();
        for (int i = 0; i < fileInput.length(); i++) {
            var isFile = i % 2 == 0;
            char c = fileInput.charAt(i);
            int value = c - '0';
            String representation;
            if (isFile) {
                int fileId = i / 2;
                representation = String.valueOf(fileId);
            } else {
                representation = ".";
            }
            for (int numCopies = 0; numCopies < value; numCopies++) {
                bigBoy.add(representation);
            }
        }
        return bigBoy;
    }

    private long calcResult(List<String> lst) {
        List<Integer> justNumbers = lst.stream()
                .map(f -> {
                    if (f.equals(".")) {
                        return "0";
                    } else {
                        return f;
                    }
                })
                .map(Integer::valueOf)
                .toList();
        long res = 0;
        for (int i = 0; i < justNumbers.size(); i++) {
            res += (long) i * justNumbers.get(i);
        }
        return res;
    }

    private List<String> part2(List<String> bigBoy) {
        List<String> bigBoyClone = new ArrayList<>(bigBoy);

        for (int rightIter = bigBoy.size() - 1; rightIter >= 0; rightIter--) {
            String rightValue = bigBoyClone.get(rightIter);
            if (!rightValue.equals(".")) {
                int tempRight = rightIter;
                List<String> wordToMove = new ArrayList<>();
                while (tempRight >= 0 && bigBoyClone.get(tempRight).equals(rightValue)) {
                    wordToMove.add(bigBoyClone.get(tempRight));
                    tempRight--;
                }
                int leftPointer = 0;

                boolean hasMoved = false;
                while (leftPointer < rightIter && !hasMoved) {
                    while (!bigBoyClone.get(leftPointer).equals(".")) {
                        leftPointer++;
                    }

                    int tempLeft = leftPointer;
                    while (tempLeft < rightIter && bigBoyClone.get(tempLeft).equals(".")) {
                        tempLeft++;
                    }

                    int spaceAvailable = tempLeft - leftPointer;
                    if (spaceAvailable >= wordToMove.size()) {
                        for (int i = 0; i < wordToMove.size(); i++) {
                            bigBoyClone.set(leftPointer + i, wordToMove.get(i));
                            bigBoyClone.set(rightIter - i, ".");
                        }
                        rightIter -= (wordToMove.size() - 1);
                        hasMoved = true;
                    } else {
                        leftPointer++;
                    }
                }
                if (!hasMoved) {
                    rightIter -= (wordToMove.size() - 1);
                }
            }
        }

        return bigBoyClone;
    }

    public String readFileToString() {
        try {
            return Files.readString(Path.of("data/input.txt"));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}

package com.aptu.sd.coffeemachine.shell;

import com.aptu.sd.coffeemachine.machine.VendingMachine;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

import java.text.MessageFormat;
import java.util.*;

public class Shell2 implements ApplicationContextAware {
    private static Shell2 ourInstance = new Shell2();
    private Map<String, Command> commands = new HashMap<>();
    private VendingMachine currentMachine;
    private VendingMachine firstMachine;
    private VendingMachine secondMachine;
    private ApplicationContext applicationContext;

    private Shell2() {

    }

    public static Shell2 getInstance() {
        return ourInstance;
    }

    public void setCommands(List<Command> commands) {
        for (Command command : commands) {
            this.commands.put(command.getClass().getSimpleName().toLowerCase(), command);
        }
    }

    public void run() {
        System.out.println("Supported commands [" + StringUtils.join(commands.keySet(), ",") + "] ");
        System.out.print(">");
        Scanner scanner = new Scanner(System.in);
        while (true) {
            String line = scanner.nextLine();
            String[] split = line.split("\\s");
            if (split.length > 0) {
                String cmdName = split[0];

                Command command = parseCommand(cmdName);
                if (command == null) {
                    System.out.println("Unknown command: " + cmdName);
                } else {
                    String[] args = Arrays.copyOfRange(split, 1, split.length);
                    try {
                        command.execute(args, getCurrentMachine());
                    } catch (CommandParseException e) {
                        System.out.println("Invalid " + cmdName + " arguments: " + StringUtils.join(args, " "));
                    }
                }
            }
        }
    }

    private Command parseCommand(String cmdName) {
        Command command = commands.get(cmdName);
        if (command == null) {
            return null;
        }
        try {
            command = applicationContext.getBean(command.getClass());
            return command;
        } catch (BeansException e) {
            System.out.println(MessageFormat.format("Bean error occurred while getting command {0}: {1}", cmdName, e.getMessage()));
            return null;
        }
    }

    public void setFirstMachine(VendingMachine firstMachine) {
        this.firstMachine = firstMachine;
    }

    public void setSecondMachine(VendingMachine secondMachine) {
        this.secondMachine = secondMachine;
    }

    public VendingMachine getCurrentMachine() {
        if (currentMachine == null) {
            currentMachine = firstMachine;
        }
        return currentMachine;
    }

    public void switchMachines() {
        if (currentMachine == firstMachine)
            currentMachine = secondMachine;
        else currentMachine = firstMachine;
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }
}

import SwiftUI

struct ContentView: View {
    @State private var display = "0"
    @State private var currentOperation: BitwiseOperation? = nil
    @State private var storedNumber: Int64? = nil
    @State private var isEnteringSecondNumber = false
    @State private var isDarkMode = false
    
    let buttonRows: [[CalculatorButton]] = [
        [.clear, .not, .leftShift, .rightShift],
        [.seven, .eight, .nine, .and],
        [.four, .five, .six, .or],
        [.one, .two, .three, .xor],
        [.zero, .delete, .equals]
    ]
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 12) {
                themeSwitchView
                Spacer()
                displayView
                keypadView
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    var backgroundView: some View {
        (isDarkMode ? Color.black : Color(.systemBackground))
            .edgesIgnoringSafeArea(.all)
    }
    
    var themeSwitchView: some View {
        Toggle(isOn: $isDarkMode) {
            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                .foregroundColor(isDarkMode ? .white : .yellow)
        }
        .padding()
    }
    
    var displayView: some View {
        Text(display)
            .font(.system(size: 64, weight: .light))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 24)
            .foregroundColor(isDarkMode ? .white : .black)
    }
    
    var keypadView: some View {
        VStack(spacing: 12) {
            ForEach(buttonRows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        CalculatorButtonView(button: button, isDarkMode: isDarkMode, action: { self.buttonTapped(button) })
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
    
    func buttonTapped(_ button: CalculatorButton) {
        switch button {
        case .clear:
            display = "0"
            currentOperation = nil
            storedNumber = nil
            isEnteringSecondNumber = false
        case .delete:
            if display.count > 1 {
                display.removeLast()
            } else {
                display = "0"
            }
        case .equals:
            performOperation()
        case .and, .or, .xor, .leftShift, .rightShift:
            performOperation()
            if let number = Int64(display) {
                storedNumber = number
                currentOperation = button.operation
                isEnteringSecondNumber = true
            }
        case .not:
            if let number = Int64(display) {
                display = String(~number)
            }
        default:
            if isEnteringSecondNumber {
                display = "0"
                isEnteringSecondNumber = false
            }
            if display == "0" {
                display = button.rawValue
            } else {
                display += button.rawValue
            }
        }
    }
    
    func performOperation() {
        guard let operation = currentOperation,
              let storedNum = storedNumber,
              let currentNum = Int64(display) else { return }
        
        let result: Int64
        switch operation {
        case .and:
            result = storedNum & currentNum
        case .or:
            result = storedNum | currentNum
        case .xor:
            result = storedNum ^ currentNum
        case .leftShift:
            result = storedNum << Int(currentNum & 63)  // Limit shift to 0-63 bits
        case .rightShift:
            result = storedNum >> Int(currentNum & 63)  // Limit shift to 0-63 bits
        case .not:
            result = ~storedNum
        }
        
        display = String(result)
        storedNumber = result
        isEnteringSecondNumber = false
    }
}

enum BitwiseOperation {
    case and, or, xor, not, leftShift, rightShift
}

enum CalculatorButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case clear = "C", delete = "⌫", equals = "="
    case and = "&", or = "|", xor = "^", not = "~"
    case leftShift = "<<", rightShift = ">>"
    
    var operation: BitwiseOperation? {
        switch self {
        case .and: return .and
        case .or: return .or
        case .xor: return .xor
        case .not: return .not
        case .leftShift: return .leftShift
        case .rightShift: return .rightShift
        default: return nil
        }
    }
}

struct CalculatorButtonView: View {
    let button: CalculatorButton
    let isDarkMode: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(button.rawValue)
                .font(.system(size: 32, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(buttonColor)
        .foregroundColor(buttonTextColor)
        .cornerRadius(12)
        .frame(width: buttonWidth, height: buttonHeight)
    }
    
    private var buttonWidth: CGFloat {
        switch button {
        case .zero:
            return (UIScreen.main.bounds.width - 5 * 12) / 2  // Span two columns, considering 5 spaces between buttons
        default:
            return (UIScreen.main.bounds.width - 5 * 12) / 4  // Normal width, 4 buttons per row
        }
    }
    
    private var buttonHeight: CGFloat {
        (UIScreen.main.bounds.width - 5 * 12) / 4  // Height is always the same as the width of a normal button
    }
    
    private var buttonColor: Color {
        switch button {
        case .clear, .delete:
            return isDarkMode ? Color(.systemGray3) : Color(.systemGray4)
        case .and, .or, .xor, .not, .leftShift, .rightShift:
            return isDarkMode ? .blue.opacity(0.8) : .blue
        case .equals:
            return isDarkMode ? .orange.opacity(0.8) : .orange
        default:
            return isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
        }
    }
    
    private var buttonTextColor: Color {
        switch button {
        case .clear, .delete, .and, .or, .xor, .not, .leftShift, .rightShift, .equals:
            return .white
        default:
            return isDarkMode ? .white : .black
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

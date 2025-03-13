import Vapor















func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.post("auth") { req async throws -> AuthenticationResponse in
        let authentication = try req.content.decode(AuthenticationRequest.self)
        if authentication.username == "test@aura.app" && authentication.password == "test123" {
            let token = AuthMiddleware.registerNewAuthToken()
            req.logger.info("Successfuly loggedin and generate new auth token: \(token)")
            return AuthenticationResponse(token: token)
        } else {
            req.logger.info("Fail to login (bad username and/or password)")
            throw Abort(.badRequest)
        }
    }
    
    app.grouped(AuthMiddleware())
        .group("account") { account in
            
        account.get { req async in
            AccountResponse(currentBalance: 5459.32, transactions: [
                .init(value: -56.4, label: "IKEA"),
                .init(value: -10, label: "Starbucks"),
                .init(value: 1400, label: "Pole Emploi"),
                .init(value: -5.8, label: "Amazon"),
                .init(value: -80.25, label: "Grocery Store"),
                .init(value: -120.00, label: "Utility Bill"),
                .init(value: -50.00, label: "Phone Bill"),
                .init(value: -900.00, label: "Monthly Rent"),
                .init(value: -40.00, label: "Gym Membership"),
                .init(value: -9.99, label: "Netflix"),
                .init(value: -15.75, label: "Pizza Place"),
                .init(value: -30.00, label: "Train Ticket"),
                .init(value: -45.00, label: "Gas Station"),
                .init(value: -75.00, label: "Dentist"),
                .init(value: -299.00, label: "Apple Store"),
                .init(value: -60.00, label: "Restaurant"),
                .init(value: -100.00, label: "Insurance"),
                .init(value: -150.00, label: "Online Course"),
                .init(value: -20.00, label: "Book Store"),
                .init(value: -25.00, label: "Hair Salon"),
                .init(value: -200.00, label: "Electronics Store"),
                .init(value: -50.00, label: "Pet Supplies"),
                .init(value: -20.00, label: "Cinema"),
                .init(value: 350.00, label: "Freelance"),
                .init(value: 100.00, label: "Gift"),
                .init(value: -6.00, label: "Coffee Shop"),
                .init(value: -40.00, label: "Taxi"),
                .init(value: -150.00, label: "Hotel Booking"),
                .init(value: -9.99, label: "Spotify"),
                .init(value: -90.00, label: "Shoe Store"),
                .init(value: -25.00, label: "Pharmacy"),
                .init(value: -20.00, label: "Public Transport"),
                .init(value: -200.00, label: "Cash Withdrawal"),
                .init(value: -50.00, label: "Game Purchase"),
                .init(value: -8.00, label: "Bakery"),
                .init(value: -12.00, label: "Cafe"),
                .init(value: -30.00, label: "Toy Store"),
                .init(value: -45.00, label: "Hardware Store"),
                .init(value: -15.00, label: "Dry Cleaning"),
                .init(value: -20.00, label: "Donation"),
                .init(value: -80.00, label: "Concert Ticket"),
                .init(value: 25.00, label: "Retailer Refund"),
                .init(value: -15.00, label: "Late Fee"),
                .init(value: 4.50, label: "Interest Earned"),
                .init(value: 250.00, label: "Work Bonus"),
                .init(value: -25.00, label: "Wine Store"),
                .init(value: -120.00, label: "Veterinary"),
                .init(value: -60.00, label: "Parking Ticket"),
                .init(value: -40.00, label: "Florist"),
                .init(value: -20.00, label: "Tailor")
            ])
        }
        
        account.post("transfer") { req async throws in
            try AccountTransferRequest.validate(content: req)
            let transfer = try req.content.decode(AccountTransferRequest.self)
            req.logger.info("Transfer \(transfer.amount) to \(transfer.recipient)")
            return ""
        }
    }
    
    
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}

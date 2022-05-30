//¿ Por qué se define vehicles como un Set?
//1 se define como un set por que esto permite que no se pueda repetir ninguno de sus elementos, no tiene que seguir un orden.

//¿Puede cambiar el tipo de vehículo en el tiempo? ¿Debe definirse como variable o como constante en Vehicle?
// Se tendria que definir como constante ya que este no deberia poder cambiar con el tiempo

//¿Qué elemento de control de flujos podría ser útil para determinar la tarifa de cada vehículo en la computed property: ciclo for, if o switch?
// Un Switch por la legitimidad del mismo y por que cumple con el proposito, Igual aclaramos que tambien podria hacerse con un If Else pero seria menos legible

//ℹ ¿Dónde deben agregarse las propiedades, en Parkable, Vehicle o en ambos?
// Se deben agregar en ambas ya que al incluirlas en el protocolo como requerimiento estas deben incluirse en cualquier clase o struct que adopte el protocolo

//ℹ La tarjeta de descuentos es opcional, es decir que un vehículo puede no tener una tarjeta y su valor será nil. ¿Qué tipo de dato de Swift permite tener este comportamiento?
// Seria un opcional.

//¿Qué tipo de propiedad permite este comportamiento: lazy properties, computed properties o static properties?
// computed properties: se computa el valor que van a tener cuando son llamadas.

//Se está modificando una propiedad de un struct ¿Qué consideración debe tenerse en la definición de la función?
// Tiene que tener la palabra reservada mutating para que justamente las propiedades dentro de la struct puedan cambiar(mutar).

import UIKit

enum StatusType: String{
    case succesfulCheckIn = "Welcome to AlkeParking!"
    case errorInserting = "Sorry, the check-in failed"
    case errorRemoving = "Sorry, the check-out failed"
    case succesfulCheckOut = "Your fee is $"
    case noParkedCars = "Currently there are no parked cars"
    case earningRegister = "vehicles have checked out and have earnings of $"
}

//MARK: - Parkable

protocol Parkable {
    var plate: String { get }
    var type: VehicleType { get }
    var checkInTime: Date { get }
    var discountCard: String? { get }
    var parkedTime: Int { get }
}

//MARK: - VehicleType

enum VehicleType {
    case auto
    case moto
    case miniBus
    case bus
    
    var typePrice: Int {
        switch self {
        case .auto:
            return 20
        case .moto:
            return 15
        case .miniBus:
            return 25
        case .bus:
            return 30
        }
    }
}

//MARK: - Vehicle

struct Vehicle: Parkable, Hashable {
    
    let plate: String
    let type: VehicleType
    let checkInTime: Date
    let discountCard: String?
    
    var parkedTime: Int {
        get{
            return Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
        }
    }
    
    init (plate: String, type: VehicleType, checkInTime: Date, discountCard: String?){
        self.plate = plate
        self.type = type
        self.checkInTime = checkInTime
        self.discountCard = discountCard
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.plate == rhs.plate
    }
}

//MARK: - Parking
enum ParkingValues: Double {
    case baseTime = 120.0
    case extraTime = 15.0
    case extraPrice = 5.0
}

struct Parking {
    
    var vehicles: Set<Vehicle>
    let limitVehicles: Int
    var earningsRegister:(Int,Int)
    
    init(vehicles: Set<Vehicle> = [], limitVehicles: Int = 20, earningsRegister:(Int,Int) = (0,0) ) {
        self.vehicles = vehicles
        self.limitVehicles = limitVehicles
        self.earningsRegister = earningsRegister
    }
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (Bool) -> Void) {
        guard vehicles.count < limitVehicles, !vehicles.contains(where: {$0 == vehicle}) else {
            return onFinish(false)
        }
        
        if vehicles.insert(vehicle).inserted {
            onFinish(true)
        }
    }
    
    mutating func checkOutVehicle (_ plate: String,onSucces: (Int)->(), onError: ()->()) {
        if let vehicleReference = vehicles.first(where: {$0.plate == plate}) {
            vehicles.remove(vehicleReference)
            onSucces(calculateFee(type: vehicleReference.type, parkedTime: vehicleReference.parkedTime, hasDiscountCard: (vehicleReference.discountCard != nil) ))
        } else {
            onError()
        }
    }
    
    mutating func calculateFee(type: VehicleType, parkedTime: Int, hasDiscountCard: Bool) -> Int{
                
        let baseFee = type.typePrice
        var fee = 0.0
        var finalFee = 0
        
        if Double(parkedTime) <= ParkingValues.baseTime.rawValue {
            fee = Double(baseFee)
        } else {
            let total = (((Double(parkedTime) - ParkingValues.baseTime.rawValue) / ParkingValues.extraTime.rawValue).rounded(.awayFromZero)) * ParkingValues.extraPrice.rawValue
            fee = total + Double(baseFee)
        }
        
        if hasDiscountCard{
            finalFee = Int(fee * 0.85)
        } else {
            finalFee = Int(fee)
        }
        
        earningsRegister.0 += 1
        earningsRegister.1 += finalFee
        
        return finalFee
        
    }
    
    func printEarningRegisters () {
        print("\(earningsRegister.0) " + StatusType.earningRegister.rawValue + "\(earningsRegister.1)")
    }
    
    func listVehicles(){
        if !vehicles.isEmpty{
            vehicles.forEach { vehicle in
                print(vehicle.plate)
            }
        } else {
            print(StatusType.noParkedCars.rawValue)
        }
    }
    
}

//MARK: Executing

var alkeParking = Parking()

let vehicle1 = Vehicle(plate: "AA111AA", type: VehicleType.auto, checkInTime: Date(timeIntervalSinceNow: -11880) ,discountCard: "DISCOUNT_CARD_001")
let vehicle2 = Vehicle(plate: "B222BBB", type: VehicleType.moto, checkInTime: Date(timeIntervalSinceNow: -11880), discountCard: nil)
let vehicle3 = Vehicle(plate: "CC333CC", type: VehicleType.miniBus, checkInTime: Date(timeIntervalSinceNow: -11880), discountCard: nil)
let vehicle4 = Vehicle(plate: "DD444DD", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_002")
let vehicle5 = Vehicle(plate: "AA111BB", type: VehicleType.auto, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003")
let vehicle6 = Vehicle(plate: "B222CCC", type: VehicleType.moto, checkInTime: Date(), discountCard: "DISCOUNT_CARD_004")
let vehicle7 = Vehicle(plate: "CC333DD", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let vehicle8 = Vehicle(plate: "DD444EE", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_005")
let vehicle9 = Vehicle(plate: "AA111CC", type: VehicleType.auto, checkInTime: Date(), discountCard: nil)
let vehicle10 = Vehicle(plate: "B222DDD", type: VehicleType.moto, checkInTime: Date(timeIntervalSinceNow: -11880), discountCard: nil)
let vehicle11 = Vehicle(plate: "CC333EE", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let vehicle12 = Vehicle(plate: "DD444GG", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_006")
let vehicle13 = Vehicle(plate: "AA111DD", type: VehicleType.auto, checkInTime: Date(), discountCard: "DISCOUNT_CARD_007")
let vehicle14 = Vehicle(plate: "B222EEE", type: VehicleType.moto, checkInTime: Date(), discountCard: nil)
let vehicle15 = Vehicle(plate: "CC444FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let vehicle16 = Vehicle(plate: "CC555FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let vehicle17 = Vehicle(plate: "CC666FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let vehicle18 = Vehicle(plate: "CC777FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let vehicle19 = Vehicle(plate: "CC123FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let vehicle20 = Vehicle(plate: "CC123FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)
let vehicle21 = Vehicle(plate: "CC123FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)

let arrayVehicles = [vehicle1,vehicle2,vehicle3,vehicle4,vehicle5,vehicle6,vehicle7,vehicle8,vehicle9,vehicle10,vehicle11,vehicle12,vehicle13,vehicle14,vehicle15,vehicle16,vehicle17,vehicle18,vehicle19,vehicle20,vehicle21]

arrayVehicles.forEach { Vehicle in
    alkeParking.checkInVehicle(Vehicle) { isTrue in
        if isTrue {
            print(StatusType.succesfulCheckIn.rawValue)
        } else {
            print(StatusType.errorInserting.rawValue)
        }
    }
}

alkeParking.vehicles.count

alkeParking.checkOutVehicle(vehicle1.plate) { precio in
    print(StatusType.succesfulCheckOut.rawValue + "\(precio) Come back soon")
} onError: {
    print(StatusType.errorRemoving.rawValue)
}

alkeParking.vehicles.count

alkeParking.printEarningRegisters()

alkeParking.checkOutVehicle(vehicle10.plate) { precio in
    print(StatusType.succesfulCheckOut.rawValue + "\(precio) Come back soon")
} onError: {
    print(StatusType.errorRemoving.rawValue)
}

alkeParking.vehicles.count

alkeParking.printEarningRegisters()

alkeParking.listVehicles()



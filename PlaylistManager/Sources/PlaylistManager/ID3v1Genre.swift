//
//  ID3v1Genre.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 09/05/26.
//

enum ID3v1Genre: Int, CaseIterable {
    case blues = 0
    case classicRock = 1
    case country = 2
    case dance = 3
    case disco = 4
    case funk = 5
    case grunge = 6
    case hipHop = 7
    case jazz = 8
    case metal = 9
    case newAge = 10
    case oldies = 11
    case other = 12
    case pop = 13
    case rAndB = 14
    case rap = 15
    case reggae = 16
    case rock = 17
    case techno = 18
    case industrial = 19
    case alternative = 20
    case ska = 21
    case deathMetal = 22
    case pranks = 23
    case soundtrack = 24
    case euroTechno = 25
    case ambient = 26
    case tripHop = 27
    case vocal = 28
    case jazzFunk = 29
    case fusion = 30
    case trance = 31
    case classical = 32
    case instrumental = 33
    case acid = 34
    case house = 35
    case game = 36
    case soundClip = 37
    case gospel = 38
    case noise = 39
    case alternativeRock = 40
    case bass = 41
    case soul = 42
    case punk = 43
    case space = 44
    case meditative = 45
    case instrumentalPop = 46
    case instrumentalRock = 47
    case ethnic = 48
    case gothic = 49
    case darkwave = 50
    case technoIndustrial = 51
    case electronic = 52
    case popFolk = 53
    case eurodance = 54
    case dream = 55
    case southernRock = 56
    case comedy = 57
    case cult = 58
    case gangsta = 59
    case top40 = 60
    case christianRap = 61
    case popFunk = 62
    case jungle = 63
    case nativeAmerican = 64
    case cabaret = 65
    case newWave = 66
    case psychedelic = 67
    case rave = 68
    case showtunes = 69
    case trailer = 70
    case loFi = 71
    case tribal = 72
    case acidPunk = 73
    case acidJazz = 74
    case polka = 75
    case retro = 76
    case musical = 77
    case rockAndRoll = 78
    case hardRock = 79

    var displayName: String {
        switch self {
        case .blues: return "Blues"
        case .classicRock: return "Classic Rock"
        case .country: return "Country"
        case .dance: return "Dance"
        case .disco: return "Disco"
        case .funk: return "Funk"
        case .grunge: return "Grunge"
        case .hipHop: return "Hip-Hop"
        case .jazz: return "Jazz"
        case .metal: return "Metal"
        case .newAge: return "New Age"
        case .oldies: return "Oldies"
        case .other: return "Other"
        case .pop: return "Pop"
        case .rAndB: return "R&B"
        case .rap: return "Rap"
        case .reggae: return "Reggae"
        case .rock: return "Rock"
        case .techno: return "Techno"
        case .industrial: return "Industrial"
        case .alternative: return "Alternative"
        case .ska: return "Ska"
        case .deathMetal: return "Death Metal"
        case .pranks: return "Pranks"
        case .soundtrack: return "Soundtrack"
        case .euroTechno: return "Euro-Techno"
        case .ambient: return "Ambient"
        case .tripHop: return "Trip-Hop"
        case .vocal: return "Vocal"
        case .jazzFunk: return "Jazz+Funk"
        case .fusion: return "Fusion"
        case .trance: return "Trance"
        case .classical: return "Classical"
        case .instrumental: return "Instrumental"
        case .acid: return "Acid"
        case .house: return "House"
        case .game: return "Game"
        case .soundClip: return "Sound Clip"
        case .gospel: return "Gospel"
        case .noise: return "Noise"
        case .alternativeRock: return "Alternative Rock"
        case .bass: return "Bass"
        case .soul: return "Soul"
        case .punk: return "Punk"
        case .space: return "Space"
        case .meditative: return "Meditative"
        case .instrumentalPop: return "Instrumental Pop"
        case .instrumentalRock: return "Instrumental Rock"
        case .ethnic: return "Ethnic"
        case .gothic: return "Gothic"
        case .darkwave: return "Darkwave"
        case .technoIndustrial: return "Techno-Industrial"
        case .electronic: return "Electronic"
        case .popFolk: return "Pop-Folk"
        case .eurodance: return "Eurodance"
        case .dream: return "Dream"
        case .southernRock: return "Southern Rock"
        case .comedy: return "Comedy"
        case .cult: return "Cult"
        case .gangsta: return "Gangsta"
        case .top40: return "Top 40"
        case .christianRap: return "Christian Rap"
        case .popFunk: return "Pop/Funk"
        case .jungle: return "Jungle"
        case .nativeAmerican: return "Native American"
        case .cabaret: return "Cabaret"
        case .newWave: return "New Wave"
        case .psychedelic: return "Psychedelic"
        case .rave: return "Rave"
        case .showtunes: return "Showtunes"
        case .trailer: return "Trailer"
        case .loFi: return "Lo-Fi"
        case .tribal: return "Tribal"
        case .acidPunk: return "Acid Punk"
        case .acidJazz: return "Acid Jazz"
        case .polka: return "Polka"
        case .retro: return "Retro"
        case .musical: return "Musical"
        case .rockAndRoll: return "Rock & Roll"
        case .hardRock: return "Hard Rock"
        }
    }
}

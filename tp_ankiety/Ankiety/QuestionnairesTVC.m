//
//  QuestionnairesTVC.m
//  tp_ankiety
//
//  Created by Aleksander Grzyb on 26/11/14.
//  Copyright (c) 2014 Aleksander Grzyb. All rights reserved.
//

#import "QuestionnairesTVC.h"
#import "QuestionnaireVC.h"
#import "QuestionnairesTVCell.h"
#import "Questionnaire.h"
#import "Question.h"
#import "constans.h"
#import "Answer.h"
#import <AFNetworking/AFHTTPSessionManager.h>

@interface QuestionnairesTVC () <UITableViewDataSource, UITableViewDelegate, QuestionnaireVCDelegate>
@property (nonatomic, strong) NSMutableArray *questionnaires;
@property (nonatomic) BOOL isRegistered;
@property (nonatomic) NSNumber *numberOfPoints;
@end

@implementation QuestionnairesTVC

#pragma mark -
#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createRefreshControl];
    [self testConnection];
    if ([self.numberOfPoints doubleValue] >= 0) {
        self.title = [NSString stringWithFormat:@"Aktualna liczba punktów - %.1f", [self.numberOfPoints doubleValue]];
    }
    else {
        self.title = [NSString stringWithFormat:@"Aktualna liczba punktów - 0"];
        
    }
//    [self addFakeData];
}

#pragma mark -
#pragma mark Getters

- (NSMutableArray *)questionnaires
{
    if (!_questionnaires) {
        _questionnaires = [[NSMutableArray alloc] init];
    }
    return _questionnaires;
}

#pragma mark -
#pragma mark Setters

- (void)setNumberOfPoints:(NSNumber *)numberOfPoints
{
    if ([numberOfPoints doubleValue] >= 0.0) {
        self.title = [NSString stringWithFormat:@"Aktualna liczba punktów - %.1f", [numberOfPoints doubleValue]];
    }
    else {
        self.title = [NSString stringWithFormat:@"Aktualna liczba punktów - 0"];
        
    }
    _numberOfPoints = numberOfPoints;
}

#pragma mark -
#pragma mark Private Methods

- (void)addFakeData
{
    Questionnaire *questionnarie1 = [[Questionnaire alloc] init];
    questionnarie1.title = @"Nibh Ligula";
    questionnarie1.timeToComplete = @(10);
    questionnarie1.author = @"Justo";
    questionnarie1.points = @(24);
    NSMutableArray *questionnarie1Questions = [[NSMutableArray alloc] init];
    Question *question1 = [[Question alloc] init];
    question1.bodyText = @"Maecenas faucibus mollis interdum. Maecenas sed diam eget risus varius blandit sit amet non magna. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.";
    question1.type = 0;
    Question *question2 = [[Question alloc] init];
    question2.bodyText = @"Nullam quis risus eget urna mollis ornare vel eu leo. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.";
    question2.type = 0;
    [questionnarie1Questions addObject:question1];
    [questionnarie1Questions addObject:question2];
    questionnarie1.questions = [questionnarie1Questions copy];
    
    Questionnaire *questionnarie2 = [[Questionnaire alloc] init];
    questionnarie2.title = @"Sem Inceptos Fringilla";
    questionnarie2.timeToComplete = @(15);
    questionnarie2.author = @"Lorem Dolor";
    questionnarie2.points = @(5);
    NSMutableArray *questionnarie2Questions = [[NSMutableArray alloc] init];
    Question *question11 = [[Question alloc] init];
    question11.bodyText = @"Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Curabitur blandit tempus porttitor. Nullam quis risus eget urna mollis ornare vel eu leo. Lorem ipsum dolor sit amet, consectetur adipiscing elit.";
    question11.type = 0;
    Question *question22 = [[Question alloc] init];
    question22.bodyText = @"Vestibulum id ligula porta felis euismod semper. Cras mattis consectetur purus sit amet fermentum.";
    question22.type = 0;
    [questionnarie2Questions addObject:question11];
    [questionnarie2Questions addObject:question22];
    questionnarie2.questions = [questionnarie2Questions copy];
    
    [self.questionnaires addObject:questionnarie1];
    [self.questionnaires addObject:questionnarie2];
}

- (void)testConnection
{
    NSURL *baseURL = [NSURL URLWithString:kBaseURL];
    NSDictionary *parameters = @{@"format" : @"json"};
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *getString = @"";
    if ([self isInitial]) {
        getString = [NSString stringWithFormat:@"polls/mobile/%@/register/", [Constans userID]];
        self.isRegistered = NO;
    }
    else {
        getString = [NSString stringWithFormat:@"polls/mobile/%@/getpoll/", [Constans userID]];
        self.isRegistered = YES;
    }
    [manager GET:getString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *questionnaireData = (NSDictionary *)responseObject;
        [self parseDataFromJSON:questionnaireData];
        [self.refreshControl endRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Networking Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [self.refreshControl endRefreshing];
        [alertView show];
    }];
}

- (void)createRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor redColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(testConnection) forControlEvents:UIControlEventValueChanged];
}

- (void)parseDataFromJSON:(NSDictionary *)questionnairesData
{
    [self.questionnaires removeAllObjects];
    if (self.isRegistered) {
        NSArray *questionnaires = [questionnairesData objectForKey:@"polls"];
        self.numberOfPoints = (NSNumber *)[questionnairesData objectForKey:@"points"];
        for (NSDictionary *questionnarieData in questionnaires) {
            Questionnaire *questionnaire = [[Questionnaire alloc] init];
            if (!self.isRegistered) {
                questionnaire.isInitial = YES;
            }
            else {
                questionnaire.isInitial = NO;
            }
            questionnaire.title = [questionnarieData valueForKey:@"title"];
            questionnaire.points = (NSNumber *)[questionnarieData valueForKey:@"points"];
            questionnaire.idNumber = [questionnarieData valueForKey:@"poll_id"];
            questionnaire.timeToComplete = (NSNumber *)[questionnarieData valueForKey:@"time_to_complete"];
            questionnaire.author = [questionnarieData valueForKey:@"author"];
            NSArray *questions = [questionnarieData valueForKey:@"questions"];
            NSMutableArray *questionObjects = [NSMutableArray array];
            for (NSDictionary *questionDictionary in questions) {
                Question *question = [[Question alloc] init];
                
                NSArray *answers = [questionDictionary valueForKey:@"available_answers"];
                NSMutableArray *correctAnswers = [NSMutableArray array];
                for (NSArray *answerData in answers) {
                    Answer *answer = [[Answer alloc] init];
                    answer.index = answerData[kAnswerIndex];
                    answer.text = answerData[kAnswerText];
                    [correctAnswers addObject:answer];
                }
                question.answers = [correctAnswers copy];
                question.idNumber = [questionDictionary valueForKey:@"id"];
                question.type = [questionDictionary valueForKey:@"question_type"];
                question.bodyText = [questionDictionary valueForKey:@"title"];
                [questionObjects addObject:question];
            }
            questionnaire.questions = [questionObjects copy];
            [self.questionnaires addObject:questionnaire];
        }
    }
    else {
        Questionnaire *questionnaire = [[Questionnaire alloc] init];
        if (!self.isRegistered) {
            questionnaire.isInitial = YES;
        }
        else {
            questionnaire.isInitial = NO;
        }
        questionnaire.title = [questionnairesData valueForKey:@"title"];
        questionnaire.points = (NSNumber *)[questionnairesData valueForKey:@"points"];
        questionnaire.idNumber = [questionnairesData valueForKey:@"poll_id"];
        questionnaire.timeToComplete = (NSNumber *)[questionnairesData valueForKey:@"time_to_complete"];
        questionnaire.author = [questionnairesData valueForKey:@"author"];
        NSArray *questions = [questionnairesData valueForKey:@"questions"];
        NSMutableArray *questionObjects = [NSMutableArray array];
        for (NSDictionary *questionDictionary in questions) {
            Question *question = [[Question alloc] init];
            
            NSArray *answers = [questionDictionary valueForKey:@"available_answers"];
            NSMutableArray *correctAnswers = [NSMutableArray array];
            for (NSArray *answerData in answers) {
                Answer *answer = [[Answer alloc] init];
                answer.index = answerData[kAnswerIndex];
                answer.text = answerData[kAnswerText];
                [correctAnswers addObject:answer];
            }
            question.answers = [correctAnswers copy];
            question.idNumber = [questionDictionary valueForKey:@"id"];
            question.type = [questionDictionary valueForKey:@"question_type"];
            question.bodyText = [questionDictionary valueForKey:@"title"];
            [questionObjects addObject:question];
        }
        questionnaire.questions = [questionObjects copy];
        [self.questionnaires addObject:questionnaire];
    }
    
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.questionnaires count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionnairesTVCell *questionnairesCell = [tableView dequeueReusableCellWithIdentifier:@"questionnairescell"];
    Questionnaire *questionnaire = [self.questionnaires objectAtIndex:indexPath.row];
    questionnairesCell.author = questionnaire.author;
    questionnairesCell.timeToComplete = questionnaire.timeToComplete;
    questionnairesCell.title = questionnaire.title;
    questionnairesCell.points = questionnaire.points;
    return questionnairesCell;
}

#pragma mark -
#pragma mark QuestionnaireVC Delegate

- (void)deleteQuestionnaireFromModel:(Questionnaire *)questionnaire
{
    if (questionnaire.isInitial) {
        [self saveRegisteredState];
    }
    [self.questionnaires removeObject:questionnaire];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"questionnaire"]) {
        QuestionnaireVC *questionnaireVC = (QuestionnaireVC *)segue.destinationViewController;
        questionnaireVC.delegateSecond = self;
        Questionnaire *questionnaire = [self.questionnaires objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        questionnaireVC.questionnaire = questionnaire;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *questionsUD = [userDefaults arrayForKey:[NSString stringWithFormat:@"%d", [questionnaire.idNumber intValue]]];
        if (!questionsUD) {
            NSMutableArray *newQuestions = [NSMutableArray array];
            for (Question *question in questionnaire.questions) {
                NSMutableDictionary *newQuestion = [NSMutableDictionary dictionary];
                NSMutableArray *newAnswers = [NSMutableArray array];
                for (Answer *answer in question.answers) {
                    NSDictionary *answerData = @{kAnswerIndexKey : answer.index,
                                                 kAnswerValueKey : answer.value};
                    [newAnswers addObject:answerData];
                }
                [newQuestion setObject:[newAnswers copy] forKey:kQuestionAnswersKey];
                [newQuestion setObject:question.idNumber forKey:kQuestionIDKey];
                [newQuestions addObject:[newQuestion copy]];
            }
            
            [userDefaults setObject:[newQuestions copy] forKey:[NSString stringWithFormat:@"%d", [questionnaire.idNumber intValue]]];
        }
        else {
            for (Question *question in questionnaire.questions) {
                for (NSDictionary *questionUD in questionsUD) {
                    if ([question.idNumber isEqualToNumber:[questionUD objectForKey:kQuestionIDKey]]) {
                        NSArray *answersUD = [questionUD objectForKey:kQuestionAnswersKey];
                        for (Answer *answer in question.answers) {
                            for (NSDictionary *answerUD in answersUD) {
                                if ([answer.index isEqualToNumber:[answerUD objectForKey:kAnswerIndexKey]]) {
                                    answer.value = [answerUD objectForKey:kAnswerValueKey];
                                }
                            }
                        }
                    }
                }
            }
        }
        [userDefaults synchronize];
    }
}

- (BOOL)isInitial
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isInitial = [userDefaults boolForKey:kInitialKey];
    return !isInitial;
}

- (void)saveRegisteredState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:true forKey:kInitialKey];
    self.isRegistered = YES;
    [userDefaults synchronize];
}

@end
